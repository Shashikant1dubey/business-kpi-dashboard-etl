-- ============================================
-- FILE: views.sql
-- PURPOSE:
-- Analytical Reporting Views
-- ============================================

USE business_kpi_dw;

-- ============================================
-- SALES SUMMARY VIEW
-- ============================================

CREATE OR REPLACE VIEW vw_sales_summary AS

SELECT

    d.year,

    d.month,

    d.month_name,

    ROUND(SUM(f.sales),2) AS total_sales,

    COUNT(DISTINCT f.order_id) AS total_orders,

    COUNT(DISTINCT f.customer_id) AS total_customers

FROM fact_sales f

LEFT JOIN dim_date d
ON f.order_date = d.order_date

GROUP BY

    d.year,
    d.month,
    d.month_name;

-- ============================================
-- REGION SALES VIEW
-- ============================================

CREATE OR REPLACE VIEW vw_region_sales AS

SELECT

    r.region,

    r.state,

    ROUND(SUM(f.sales),2) AS total_sales

FROM fact_sales f

LEFT JOIN sales_raw sr
ON f.row_id = sr.row_id

LEFT JOIN dim_region r
ON sr.postal_code = r.postal_code

GROUP BY

    r.region,
    r.state;

-- ============================================
-- PRODUCT PERFORMANCE VIEW
-- ============================================

CREATE OR REPLACE VIEW vw_product_performance AS

SELECT

    p.category,

    p.sub_category,

    p.product_name,

    ROUND(SUM(f.sales),2) AS total_sales

FROM fact_sales f

LEFT JOIN dim_product p
ON f.product_id = p.product_id

GROUP BY

    p.category,
    p.sub_category,
    p.product_name;

-- ============================================
-- CUSTOMER SEGMENT VIEW
-- ============================================

CREATE OR REPLACE VIEW vw_customer_segment AS

SELECT

    c.segment,

    ROUND(SUM(f.sales),2) AS total_sales,

    COUNT(DISTINCT f.customer_id) AS total_customers

FROM fact_sales f

LEFT JOIN dim_customer c
ON f.customer_id = c.customer_id

GROUP BY c.segment;