-- ============================================================
-- 02 - CUSTOMER SUMMARY & RETENTION
-- ============================================================

-- SOURCE TABLE:
-- customer_orders

-- OUTPUT TABLE:
-- customer_summary


CREATE OR REPLACE TABLE
`e-commerce-retention-analysis.ecommerce_retention.customer_summary`
AS

SELECT
    customer_id,
    COUNT(DISTINCT invoice) AS total_orders,
    SUM(order_revenue) AS total_revenue,
    AVG(order_revenue) AS avg_order_value,
    SUM(total_items) AS total_items,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,

    DATE_DIFF(
        DATE(MAX(order_date)),
        DATE(MIN(order_date)),
        DAY
    ) AS customer_lifetime_days,

    CASE
        WHEN COUNT(DISTINCT invoice) = 1
            THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type

FROM `e-commerce-retention-analysis.ecommerce_retention.customer_orders`

GROUP BY customer_id;


-- ============================================================
-- CUSTOMER TYPE DISTRIBUTION
-- ============================================================

SELECT
    customer_type,
    COUNT(*) AS customers,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage,

    ROUND(AVG(total_revenue), 2) AS avg_customer_revenue,
    ROUND(AVG(total_orders), 2) AS avg_orders

FROM `e-commerce-retention-analysis.ecommerce_retention.customer_summary`

GROUP BY customer_type
ORDER BY customers DESC;


-- ============================================================
-- PURCHASE FREQUENCY
-- ============================================================

SELECT
    total_orders,
    COUNT(*) AS customers,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage

FROM `e-commerce-retention-analysis.ecommerce_retention.customer_summary`

GROUP BY total_orders
ORDER BY total_orders;


-- ============================================================
-- FIRST-TO-SECOND ORDER CONVERSION
-- ============================================================

WITH ranked_orders AS (

    SELECT
        customer_id,
        invoice,
        order_date,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date, invoice
        ) AS order_number

    FROM `e-commerce-retention-analysis.ecommerce_retention.customer_orders`
),

customer_conversion AS (

    SELECT
        customer_id,
        MAX(order_number) AS total_orders

    FROM ranked_orders
    GROUP BY customer_id
)

SELECT
    COUNT(*) AS total_customers,

    COUNTIF(total_orders >= 2)
        AS customers_with_second_order,

    ROUND(
        COUNTIF(total_orders >= 2)
        * 100.0 / COUNT(*),
        2
    ) AS first_to_second_order_conversion

FROM customer_conversion;