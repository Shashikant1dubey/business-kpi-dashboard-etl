-- ============================================
-- FILE: kpi_queries.sql
-- PURPOSE:
-- Business KPI Queries
-- ============================================

USE business_kpi_dw;

-- ============================================
-- TOTAL SALES
-- ============================================

SELECT
    ROUND(SUM(sales),2) AS total_sales
FROM fact_sales;

-- ============================================
-- TOTAL ORDERS
-- ============================================

SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM fact_sales;

-- ============================================
-- TOTAL CUSTOMERS
-- ============================================

SELECT
    COUNT(DISTINCT customer_id) AS total_customers
FROM fact_sales;

-- ============================================
-- AVERAGE ORDER VALUE
-- ============================================

SELECT

    ROUND(
        SUM(sales) /
        COUNT(DISTINCT order_id),
        2
    ) AS avg_order_value

FROM fact_sales;

-- ============================================
-- TOP 10 PRODUCTS
-- ============================================

SELECT

    p.product_name,

    ROUND(SUM(f.sales),2) AS total_sales

FROM fact_sales f

LEFT JOIN dim_product p
ON f.product_id = p.product_id

GROUP BY p.product_name

ORDER BY total_sales DESC

LIMIT 10;

-- ============================================
-- TOP STATES
-- ============================================

SELECT

    r.state,

    ROUND(SUM(f.sales),2) AS total_sales

FROM fact_sales f

LEFT JOIN dim_region r
ON f.postal_code = r.postal_code

GROUP BY r.state

ORDER BY total_sales DESC;

-- ============================================
-- SALES BY CATEGORY
-- ============================================

SELECT

    p.category,

    ROUND(SUM(f.sales),2) AS total_sales

FROM fact_sales f

LEFT JOIN dim_product p
ON f.product_id = p.product_id

GROUP BY p.category;

-- ============================================
-- MONTHLY SALES TREND
-- ============================================

SELECT

    d.year,
    d.month_name,

    ROUND(SUM(f.sales),2) AS total_sales

FROM fact_sales f

LEFT JOIN dim_date d
ON f.order_date = d.date_id

GROUP BY
    d.year,
    d.month_name

ORDER BY
    d.year,
    d.month;

-- ============================================
-- CUSTOMER SEGMENT PERFORMANCE
-- ============================================

SELECT

    c.segment,

    ROUND(SUM(f.sales),2) AS total_sales

FROM fact_sales f

LEFT JOIN dim_customer c
ON f.customer_id = c.customer_id

GROUP BY c.segment;

-- ============================================
-- DAILY SALES KPI
-- ============================================

SELECT

    order_date,

    ROUND(SUM(sales),2) AS daily_sales

FROM fact_sales

GROUP BY order_date

ORDER BY order_date;