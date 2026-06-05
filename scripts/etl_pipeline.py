# STEP 10 — ADD BASIC SETUP
from pathlib import Path
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

# STEP 13 — SETUP LOGGING
logger.add(
    LOG_DIR / "etl.log",
    rotation="1 MB"
)

logger.info("Pipeline Started")

# STEP 14 — CONNECT MYSQL
engine = create_engine(
    f"mysql+pymysql://{MYSQL_USER}:{MYSQL_PASSWORD}@{MYSQL_HOST}/{MYSQL_DATABASE}"
)

# STEP 15 — DETECT FILES
files = list(RAW_DIR.glob("*.csv"))

logger.info(f"Files Found: {len(files)}")

# STEP 16 — PROCESS FILES
for file in files:

    try:

        logger.info(f"Processing {file.name}")

        # READ CSV
        df = pd.read_csv(
            file,
            encoding='latin1'
        )

        # STEP 17 — CLEAN COLUMN NAMES
        df.columns = [
            col.strip()
            .replace(" ", "_")
            .replace("-", "_")
            .replace("/", "_")
            .lower()
            for col in df.columns
        ]

        logger.info("Column names cleaned")

        # STEP 18 — FIX DATES
        df['order_date'] = pd.to_datetime(
            df['order_date'],
            errors='coerce'
        )

        df['ship_date'] = pd.to_datetime(
            df['ship_date'],
            errors='coerce'
        )

        logger.info("Date columns fixed")

        # STEP 19 — GET LAST LOADED ROW
        control_query = """
        SELECT last_loaded_row_id
        FROM etl_control
        ORDER BY id DESC
        LIMIT 1
        """

        control_df = pd.read_sql(
            control_query,
            engine
        )

        # HANDLE EMPTY CONTROL TABLE
        if control_df.empty:

            last_row_id = 0

        else:

            last_row_id = control_df.iloc[0, 0]

            if pd.isna(last_row_id):
                last_row_id = 0

        logger.info(f"Last Loaded Row ID: {last_row_id}")

        # FILTER ONLY NEW RECORDS
        df = df[
            df['row_id'] > last_row_id
        ]

        logger.info(f"New Rows Found: {len(df)}")

        # STEP 20 — HANDLE EMPTY DATAFRAME
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

        # STEP 21 — ADD SOURCE FILE
        df['source_file'] = file.name

        # STEP 22 — LOAD DATA INTO MYSQL
        df.to_sql(
            "sales_raw",
            engine,
            if_exists="append",
            index=False,
            chunksize=1000,
            method="multi"
        )

        logger.success(
            f"{len(df)} rows loaded into sales_raw"
        )

        # ==================================================
        # STEP 23 — LOAD DIMENSION TABLES
        # ==================================================

        with engine.begin() as connection:

            # DIM CUSTOMER
            connection.execute(text("""

                INSERT IGNORE INTO dim_customer (

                    customer_id,
                    customer_name,
                    segment

                )

                SELECT

                    customer_id,
                    MAX(customer_name),
                    MAX(segment)

                FROM sales_raw

                GROUP BY customer_id

            """))

            logger.info("dim_customer loaded")


            # DIM PRODUCT
            connection.execute(text("""

                INSERT IGNORE INTO dim_product (

                    product_id,
                    category,
                    sub_category,
                    product_name

                )

                SELECT

                    product_id,
                    MAX(category),
                    MAX(sub_category),
                    MAX(product_name)

                FROM sales_raw

                GROUP BY product_id

            """))

            logger.info("dim_product loaded")


            # DIM REGION
            connection.execute(text("""

                INSERT IGNORE INTO dim_region (

                    country,
                    state,
                    city,
                    region,
                    postal_code

                )

                SELECT DISTINCT

                    country,
                    state,
                    city,
                    region,
                    postal_code

                FROM sales_raw

            """))

            logger.info("dim_region loaded")


            # DIM DATE
            connection.execute(text("""

                INSERT IGNORE INTO dim_date (

                    order_date,
                    year,
                    month,
                    month_name,
                    quarter

                )

                SELECT DISTINCT

                    order_date,
                    YEAR(order_date),
                    MONTH(order_date),
                    MONTHNAME(order_date),
                    QUARTER(order_date)

                FROM sales_raw

                WHERE order_date IS NOT NULL

            """))

            logger.info("dim_date loaded")

        # ==================================================
        # STEP 24 — LOAD FACT TABLE
        # ==================================================

        with engine.begin() as connection:

            # FACT SALES
            connection.execute(text("""

                INSERT IGNORE INTO fact_sales (

                    row_id,
                    order_id,
                    order_date,
                    ship_date,
                    customer_id,
                    product_id,
                    postal_code,
                    sales,
                    source_file

                )

                SELECT

                    row_id,
                    order_id,
                    order_date,
                    ship_date,
                    customer_id,
                    product_id,
                    postal_code,
                    sales,
                    source_file

                FROM sales_raw;

            """))

        logger.success("fact_sales loaded")

        # STEP 23 — UPDATE CONTROL TABLE
        max_row_id = int(df['row_id'].max())

        with engine.begin() as connection:

            connection.execute(
                text("""
                    UPDATE etl_control
                    SET
                        last_loaded_row_id = :row_id,
                        last_run = NOW()
                    WHERE id = 1
                """),
                {
                    "row_id": max_row_id
                }
            )

        logger.info(
            f"ETL Control Updated: {max_row_id}"
        )

        # STEP 24 — MOVE FILE TO ARCHIVE
        archive_path = ARCHIVE_DIR / file.name

        file.rename(archive_path)

        logger.success(
            f"{file.name} archived successfully"
        )

    # STEP 25 — ERROR HANDLING
    except Exception as e:

        logger.error(str(e))

        failed_path = FAILED_DIR / file.name

        file.rename(failed_path)

        logger.error(
            f"{file.name} moved to failed folder"
        )

# STEP 26 — PIPELINE END
logger.success("Pipeline Completed")
