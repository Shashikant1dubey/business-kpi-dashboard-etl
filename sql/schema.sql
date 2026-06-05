-- ============================================
-- FILE: schema.sql
-- PURPOSE:
-- Create Database Schema
-- ============================================

CREATE DATABASE IF NOT EXISTS business_kpi_dw;

USE business_kpi_dw;

-- ============================================
-- RAW SALES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS sales_raw (

    row_id INT PRIMARY KEY,

    order_id VARCHAR(50),

    order_date DATETIME,

    ship_date DATETIME,

    ship_mode VARCHAR(100),

    customer_id VARCHAR(50),

    customer_name VARCHAR(255),

    segment VARCHAR(100),

    country VARCHAR(100),

    city VARCHAR(100),

    state VARCHAR(100),

    postal_code VARCHAR(20),

    region VARCHAR(100),

    product_id VARCHAR(100),

    category VARCHAR(100),

    sub_category VARCHAR(100),

    product_name TEXT,

    sales DECIMAL(10,2),

    source_file VARCHAR(255),

    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ============================================
-- CUSTOMER DIMENSION
-- ============================================

CREATE TABLE IF NOT EXISTS dim_customer (

    customer_id VARCHAR(50) PRIMARY KEY,

    customer_name VARCHAR(255),

    segment VARCHAR(100)

);

-- ============================================
-- PRODUCT DIMENSION
-- ============================================

CREATE TABLE IF NOT EXISTS dim_product (

    product_id VARCHAR(100) PRIMARY KEY,

    category VARCHAR(100),

    sub_category VARCHAR(100),

    product_name TEXT

);

-- ============================================
-- REGION DIMENSION
-- ============================================

CREATE TABLE IF NOT EXISTS dim_region (

    region_id INT AUTO_INCREMENT PRIMARY KEY,

    country VARCHAR(100),

    state VARCHAR(100),

    city VARCHAR(100),

    region VARCHAR(100),

    postal_code VARCHAR(20)

);

-- ============================================
-- DATE DIMENSION
-- ============================================

CREATE TABLE IF NOT EXISTS dim_date (

    order_date DATE PRIMARY KEY,

    year INT,

    month INT,

    month_name VARCHAR(20),

    quarter INT

);

-- ============================================
-- FACT SALES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS fact_sales (

    row_id INT PRIMARY KEY,

    order_id VARCHAR(50),

    order_date DATE,

    ship_date DATE,

    customer_id VARCHAR(50),

    product_id VARCHAR(100),

    postal_code VARCHAR(20),

    sales DECIMAL(10,2),

    source_file VARCHAR(255),

    FOREIGN KEY (customer_id)
    REFERENCES dim_customer(customer_id),

    FOREIGN KEY (product_id)
    REFERENCES dim_product(product_id)

);

-- ============================================
-- ETL CONTROL TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS etl_control (

    id INT PRIMARY KEY AUTO_INCREMENT,

    last_loaded_row_id INT,

    last_run TIMESTAMP

);

-- ============================================
-- INITIAL CONTROL RECORD
-- ============================================

INSERT IGNORE INTO etl_control (

    id,
    last_loaded_row_id,
    last_run

)

VALUES (

    1,
    0,
    NOW()

);