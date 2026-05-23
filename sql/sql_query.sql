CREATE DATABASE sales_warehouse;

# STEP 6 — CREATE STAR SCHEMA


-- CREATE dim_customer
USE sales_warehouse;

CREATE TABLE dim_customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50)
);

-- CREATE dim_product
CREATE TABLE dim_product (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255)
);

-- CREATE dim_region
CREATE TABLE dim_region (
    region_key INT AUTO_INCREMENT PRIMARY KEY,
    country VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    postal_code INT,
    region VARCHAR(50)
);

-- CREATE fact_sales
CREATE TABLE fact_sales (
    sales_key INT AUTO_INCREMENT PRIMARY KEY,
    
    row_id INT,
    order_id VARCHAR(50),

    customer_id VARCHAR(50),
    product_id VARCHAR(50),

    order_date DATE,
    ship_date DATE,

    sales DOUBLE,
    
    source_file VARCHAR(255)
);

-- WHY STAR SCHEMA?
-- Because companies separate:
-- customer info
-- product info
-- sales data

-- This makes:
-- ✅ faster dashboards
-- ✅ scalable systems
-- ✅ cleaner architecture


# STEP 7 — CREATE CONTROL TABLE

-- VERY IMPORTANT.
-- This remembers:
-- “What was the last row loaded?”

CREATE TABLE IF NOT EXISTS etl_control (
    id INT PRIMARY KEY,
    last_loaded_row_id BIGINT,
    last_run DATETIME
);

INSERT INTO etl_control VALUES (1, 0, NOW());

Select * from etl_control;

-- WHY?
-- Without this: pipeline reloads ALL rows every time.

-- With this: pipeline loads ONLY NEW rows.
-- VERY FAST.

# STEP 8 — CREATE AUDIT TABLE
-- This is your report card.
-- It records:
-- 	when pipeline ran
-- 	success/failure
-- 	rows inserted

CREATE TABLE etl_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    file_name VARCHAR(255),
    rows_processed INT,
    status VARCHAR(20),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


Select * from etl_control;

Select * from etl_audit;
