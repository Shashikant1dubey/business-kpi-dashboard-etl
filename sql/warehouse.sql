-- ============================================
-- FILE: warehouse.sql
-- PURPOSE:
-- Load Dimension & Fact Tables
-- ============================================

USE business_kpi_dw;

-- ============================================
-- LOAD CUSTOMER DIMENSION
-- ============================================

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

GROUP BY customer_id;

-- ============================================
-- LOAD PRODUCT DIMENSION
-- ============================================

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

GROUP BY product_id;

-- ============================================
-- LOAD REGION DIMENSION
-- ============================================

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

FROM sales_raw;

-- ============================================
-- LOAD DATE DIMENSION
-- ============================================

INSERT IGNORE INTO dim_date (

    order_date,
    year,
    month,
    month_name,
    quarter

)

SELECT DISTINCT

    DATE(order_date),

    YEAR(order_date),

    MONTH(order_date),

    MONTHNAME(order_date),

    QUARTER(order_date)

FROM sales_raw

WHERE order_date IS NOT NULL;

-- ============================================
-- LOAD FACT SALES
-- ============================================

INSERT IGNORE INTO fact_sales (

    row_id,
    order_id,
    order_date,
    ship_date,
    customer_id,
    product_id,
    sales,
    source_file

)

SELECT

    row_id,

    order_id,

    DATE(order_date),

    DATE(ship_date),

    customer_id,

    product_id,

    sales,

    source_file

FROM sales_raw;