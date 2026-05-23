# 🚀 Business KPI Dashboard — Production ETL + Data Warehouse + Power BI

## 📌 Project Overview

Designed and developed a production-style ETL and Business Intelligence solution using Python, MySQL, and Power BI.

The project automates:
- CSV ingestion
- Data cleaning
- Incremental ETL loading
- Data warehousing
- Logging & monitoring
- File archival
- Power BI reporting

---

# 🏗️ Architecture

Raw CSV Files
↓
Python ETL Pipeline
↓
Staging Layer
↓
MySQL Data Warehouse
↓
Fact & Dimension Tables
↓
SQL Views / KPI Layer
↓
Power BI Dashboard

---

# ⚙️ Tech Stack

- Python
- Pandas
- SQLAlchemy
- MySQL
- Loguru
- Power BI
- Windows Task Scheduler
- Git & GitHub

---

# 🚀 Features

## ✅ Automated ETL Pipeline
- Detects new CSV files automatically
- Incremental loading using ETL control table
- Handles failed files separately
- Archives processed files

## ✅ Production Logging
- Centralized logging using Loguru
- Error tracking and debugging

## ✅ Data Warehouse Design
Implemented Star Schema architecture:
- fact_sales
- dim_customer
- dim_product
- dim_region
- dim_date

## ✅ KPI Reporting
Built advanced KPIs:
- Total Sales
- Sales by Region
- Monthly Trends
- Customer Segmentation
- Contribution %
- Shipping Delay Analysis

## ✅ Power BI Dashboard
Interactive dashboard connected directly to MySQL with refresh capability.

---

# 📂 Folder Structure

```text
Business-KPI-Dashboard_Pro/
│
├── config/
├── data/
├── logs/
├── scripts/
├── sql/
├── powerbi/
└── README.md



▶️ Run ETL Pipeline
python .\scripts\etl_pipeline.py