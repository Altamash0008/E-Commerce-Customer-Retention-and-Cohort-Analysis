-- ============================================================
-- 06 - COHORT RETENTION ANALYSIS
-- ============================================================

-- SOURCE TABLES:
-- customer_summary
-- customer_orders

-- OUTPUT TABLES:
-- customer_cohorts
-- cohort_activity
-- cohort_retention


-- ============================================================
-- 1. CUSTOMER ACQUISITION COHORTS
-- ============================================================

CREATE OR REPLACE TABLE
`e-commerce-retention-analysis.ecommerce_retention.customer_cohorts`
AS

SELECT
    customer_id,
    total_orders,
    total_revenue,
    avg_order_value,
    total_items,
    first_order_date,
    last_order_date,
    customer_lifetime_days,
    customer_type,

    DATE_TRUNC(
        DATE(first_order_date),
        MONTH
    ) AS cohort_month

FROM `e-commerce-retention-analysis.ecommerce_retention.customer_summary`;


-- ============================================================
-- 2. COHORT SIZE
-- ============================================================

SELECT
    cohort_month,
    COUNT(*) AS customers

FROM `e-commerce-retention-analysis.ecommerce_retention.customer_cohorts`

GROUP BY cohort_month
ORDER BY cohort_month;


-- ============================================================
-- 3. CUSTOMER ACTIVITY BY COHORT
-- ============================================================

CREATE OR REPLACE TABLE
`e-commerce-retention-analysis.ecommerce_retention.cohort_activity`
AS

SELECT DISTINCT
    o.customer_id,
    c.cohort_month,

    DATE_TRUNC(
        DATE(o.order_date),
        MONTH
    ) AS order_month,

    DATE_DIFF(
        DATE_TRUNC(
            DATE(o.order_date),
            MONTH
        ),
        c.cohort_month,
        MONTH
    ) AS cohort_index

FROM `e-commerce-retention-analysis.ecommerce_retention.customer_orders` o

JOIN `e-commerce-retention-analysis.ecommerce_retention.customer_cohorts` c

ON o.customer_id = c.customer_id;


-- ============================================================
-- 4. COHORT RETENTION
-- ============================================================

CREATE OR REPLACE TABLE
`e-commerce-retention-analysis.ecommerce_retention.cohort_retention`
AS

WITH cohort_activity_summary AS (

    SELECT
        cohort_month,
        cohort_index,
        COUNT(DISTINCT customer_id) AS active_customers

    FROM `e-commerce-retention-analysis.ecommerce_retention.cohort_activity`

    GROUP BY
        cohort_month,
        cohort_index
),

cohort_sizes AS (

    SELECT
        cohort_month,
        active_customers AS cohort_size

    FROM cohort_activity_summary

    WHERE cohort_index = 0
)

SELECT
    a.cohort_month,
    a.cohort_index,
    a.active_customers,
    c.cohort_size,

    SAFE_DIVIDE(
        a.active_customers,
        c.cohort_size
    ) AS retention_rate

FROM cohort_activity_summary a

LEFT JOIN cohort_sizes c

ON a.cohort_month = c.cohort_month

ORDER BY
    a.cohort_month,
    a.cohort_index;