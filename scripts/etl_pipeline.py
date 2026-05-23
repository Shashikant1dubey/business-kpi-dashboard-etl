# STEP 10 — ADD BASIC SETUP
from pathlib import Path
from pickle import loads
from loguru import logger
from dotenv import load_dotenv

import pandas as pd
import os

from sqlalchemy import create_engine, text

# STEP 11 — LOAD ENV VARIABLES
load_dotenv()

MYSQL_USER = os.getenv("MYSQL_USER")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD")
MYSQL_HOST = os.getenv("MYSQL_HOST")
MYSQL_DATABASE = os.getenv("MYSQL_DATABASE")

# STEP 12 — CREATE FOLDER PATHS

BASE_DIR = Path(__file__).resolve().parent.parent

RAW_DIR = BASE_DIR / "data" / "raw"
ARCHIVE_DIR = BASE_DIR / "data" / "archive"
FAILED_DIR = BASE_DIR / "data" / "failed"
LOG_DIR = BASE_DIR / "logs"

LOG_DIR.mkdir(parents=True, exist_ok=True)
ARCHIVE_DIR.mkdir(parents=True, exist_ok=True)
FAILED_DIR.mkdir(parents=True, exist_ok=True)

# WHY?
# This creates folders automatically if missing.


# STEP 13 — SETUP LOGGING
logger.add(
    LOG_DIR / "etl.log",
    rotation="1 MB"
)

logger.info("Pipeline Started")

# WHAT IS LOGGING?
# Imagine CCTV camera for your pipeline.
# It records everything.


# STEP 14 — CONNECT MYSQL
engine = create_engine(
    f"mysql+pymysql://{MYSQL_USER}:{MYSQL_PASSWORD}@{MYSQL_HOST}/{MYSQL_DATABASE}"
)

# STEP 15 — DETECT FILES
files = list(RAW_DIR.glob("*.csv"))
logger.info(f"Files Found: {len(files)}")

# WHAT THIS DOES
# Looks inside:
#               data/raw
# and finds CSV files automatically.


# STEP 16 — READ FILE ONE BY ONE
for file in files:

    try:

        logger.info(f"Processing {file.name}")

        df = pd.read_csv(
            file,
            encoding='latin1'
        )

# STEP 17 — CLEAN DATA

        df.columns = [
            col.strip().replace(" ", "_").lower()
            for col in df.columns
        ]    
# STEP 18 — FIX DATES
        df['order_date'] = pd.to_datetime(
            df['order_date'],
            errors='coerce'
        )

        df['ship_date'] = pd.to_datetime(
            df['ship_date'],
            errors='coerce'
        )

# STEP 19 — LOAD ONLY NEW ROWS 
        control_query = """
        SELECT last_loaded_row_id
        FROM etl_control
        ORDER BY id DESC
        LIMIT 1
        """

        last_row_id = pd.read_sql(
            control_query,
            engine
        ).iloc[0,0] 

# Filter only new rows         
        df = df[
            df['row_id'] > last_row_id
        ]

# WHAT THIS DOES

# If last loaded row was: 9800
# then:
#         9801 loads
#         9802 loads
#         older rows ignored
# VERY FAST.

# ✅ CHECK EMPTY DATAFRAME
        if df.empty:

            logger.warning(
                f"No new rows found in {file.name}"
            )

            archive_path = ARCHIVE_DIR / file.name
            file.rename(archive_path)

            logger.info(
                f"{file.name} archived (no new rows)"
            )

            continue

# STEP 20 — ADD SOURCE FILE

        df['source_file'] = file.name


# STEP 21 — LOAD FACT TABLE

        df.to_sql(
            "fact_sales",
            engine,
            if_exists="append",
            index=False,
            chunksize=1000,
            method="multi"
        )

# STEP 22 — UPDATE CONTROL TABLE
        max_row_id = df['row_id'].max()

        with engine.begin() as connection:
            connection.execute(
                text("""
            UPDATE etl_control
            SET
                last_loaded_row_id = :row_id,
                last_run = NOW()
            WHERE id = 1
        """),
        {"row_id": int(max_row_id)}
    )
        logger.info(f"ETL Control Updated: {max_row_id}")


# STEP 23 — MOVE FILE TO ARCHIVE
        archive_path = ARCHIVE_DIR / file.name

        file.rename(archive_path)

        logger.success(f"{file.name} archived")

# STEP 24 — HANDLE ERRORS
    except Exception as e:

        logger.error(str(e))

        failed_path = FAILED_DIR / file.name

        file.rename(failed_path)

# WHAT THIS DOES
# If file breaks:
#    move to failed folder
#    pipeline continues
# This is REAL production behavior.  
 

# STEP 25 — RUN PIPELINE
# Go to root:
# cd "C:\Users\shash\Documents\Project\Business_KPI_Dashboard"

# Run:
# python .\scripts\etl_pipeline.py