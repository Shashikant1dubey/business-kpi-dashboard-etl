-- ============================================
-- FILE: schema.sql
-- PURPOSE:
-- Create raw operational tables
-- ============================================

CREATE DATABASE IF NOT EXISTS business_kpi_dw;

USE business_kpi_dw;

-- ============================================
-- ETL CONTROL TABLE
-- Tracks latest loaded row
-- ============================================

CREATE TABLE IF NOT EXISTS etl_control (
    id INT PRIMARY KEY AUTO_INCREMENT,
    last_loaded_row_id BIGINT,
    last_run TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO etl_control (
    last_loaded_row_id
)
SELECT 0
WHERE NOT EXISTS (
    SELECT 1 FROM etl_control
);

-- ============================================
-- FACT SALES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS fact_sales (

    row_id BIGINT PRIMARY KEY,

    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,

    customer_id VARCHAR(50),
    product_id VARCHAR(50),

    ship_mode VARCHAR(100),

    sales DECIMAL(12,2),

    postal_code INT,

    source_file VARCHAR(255),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- DIM CUSTOMER
-- ============================================

CREATE TABLE IF NOT EXISTS dim_customer (

    customer_id VARCHAR(50) PRIMARY KEY,

    customer_name VARCHAR(255),

    segment VARCHAR(100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- DIM PRODUCT
-- ============================================

CREATE TABLE IF NOT EXISTS dim_product (

    product_id VARCHAR(50) PRIMARY KEY,

    category VARCHAR(100),

    sub_category VARCHAR(100),

    product_name VARCHAR(255),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- DIM REGION
-- ============================================

CREATE TABLE IF NOT EXISTS dim_region (

    region_id INT PRIMARY KEY AUTO_INCREMENT,

    country VARCHAR(100),

    state VARCHAR(100),

    city VARCHAR(100),

    region VARCHAR(100),

    postal_code INT
);

-- ============================================
-- DIM DATE
-- ============================================

CREATE TABLE IF NOT EXISTS dim_date (

    date_id DATE PRIMARY KEY,

    year INT,

    quarter INT,

    month INT,

    month_name VARCHAR(20),

    day INT,

    weekday_name VARCHAR(20)
);