-- ============================================================
-- 03 - CUSTOMER VALUE & RFM ANALYSIS
-- ============================================================

-- SOURCE TABLES:
-- clean_transactions
-- customer_revenue

-- OUTPUT TABLES:
-- customer_revenue
-- customer_value
-- customer_rfm


-- ============================================================
-- CUSTOMER REVENUE
-- ============================================================

CREATE OR REPLACE TABLE
`e-commerce-retention-analysis.ecommerce_retention.customer_revenue`
AS

SELECT
    Customer_ID,
    COUNT(DISTINCT Invoice) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(
        SUM(revenue) / COUNT(DISTINCT Invoice),
        2
    ) AS avg_order_value,

    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date

FROM `e-commerce-retention-analysis.ecommerce_retention.clean_transactions`

GROUP BY Customer_ID;


-- ============================================================
-- CUSTOMER VALUE SEGMENTATION
-- ============================================================

CREATE OR REPLACE TABLE
`e-commerce-retention-analysis.ecommerce_retention.customer_value`
AS

SELECT
    Customer_ID,
    total_orders,
    total_revenue,
    avg_order_value,
    first_order_date,
    last_order_date,

    CASE
        WHEN total_revenue >= 5000
            THEN 'High Value'

        WHEN total_revenue >= 1000
            THEN 'Medium Value'

        ELSE 'Low Value'
    END AS customer_value_segment

FROM `e-commerce-retention-analysis.ecommerce_retention.customer_revenue`;


-- ============================================================
-- RFM BASE TABLE
-- ============================================================

CREATE OR REPLACE TABLE
`e-commerce-retention-analysis.ecommerce_retention.customer_rfm`
AS

SELECT
    Customer_ID,

    DATE_DIFF(
        (
            SELECT MAX(order_date)
            FROM `e-commerce-retention-analysis.ecommerce_retention.clean_transactions`
        ),
        last_order_date,
        DAY
    ) AS recency,

    total_orders AS frequency,
    total_revenue AS monetary

FROM `e-commerce-retention-analysis.ecommerce_retention.customer_revenue`;