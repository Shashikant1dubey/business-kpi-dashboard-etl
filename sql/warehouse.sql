-- ============================================
-- FILE: warehouse.sql
-- PURPOSE:
-- Populate Data Warehouse Tables
-- ============================================

USE business_kpi_dw;

-- ============================================
-- LOAD DIM CUSTOMER
-- ============================================

INSERT IGNORE INTO dim_customer (
    customer_id,
    customer_name,
    segment
)
SELECT DISTINCT
    customer_id,
    customer_name,
    segment
FROM sales_raw;

-- ============================================
-- LOAD DIM PRODUCT
-- ============================================

INSERT IGNORE INTO dim_product (
    product_id,
    category,
    sub_category,
    product_name
)
SELECT DISTINCT
    product_id,
    category,
    sub_category,
    product_name
FROM sales_raw;

-- ============================================
-- LOAD DIM REGION
-- ============================================

INSERT INTO dim_region (
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
FROM sales_raw;

-- ============================================
-- LOAD DIM DATE
-- ============================================

INSERT IGNORE INTO dim_date (
    date_id,
    year,
    quarter,
    month,
    month_name,
    day,
    weekday_name
)
SELECT DISTINCT

    order_date,

    YEAR(order_date),

    QUARTER(order_date),

    MONTH(order_date),

    MONTHNAME(order_date),

    DAY(order_date),

    DAYNAME(order_date)

FROM sales_raw
WHERE order_date IS NOT NULL;

-- ============================================
-- LOAD FACT SALES
-- ============================================

INSERT INTO fact_sales (

    row_id,
    order_id,
    order_date,
    ship_date,
    customer_id,
    product_id,
    ship_mode,
    sales,
    postal_code,
    source_file

)
SELECT

    row_id,
    order_id,
    order_date,
    ship_date,
    customer_id,
    product_id,
    ship_mode,
    sales,
    postal_code,
    source_file

FROM sales_raw;