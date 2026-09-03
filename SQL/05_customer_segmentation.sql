-- ============================================================
-- 05 - CUSTOMER SEGMENTATION
-- ============================================================

-- SOURCE:
-- customer_rfm_final

-- OUTPUT:
-- customer_segments


CREATE OR REPLACE TABLE
`e-commerce-retention-analysis.ecommerce_retention.customer_segments`
AS

SELECT
    Customer_ID,
    recency,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    rfm_score,
    rfm_total,

    CASE

        WHEN recency_score >= 4
             AND frequency_score >= 4
             AND monetary_score >= 4
            THEN 'Champions'

        WHEN recency_score >= 3
             AND frequency_score >= 4
             AND monetary_score >= 3
            THEN 'Loyal Customers'

        WHEN recency_score >= 4
             AND frequency_score >= 2
             AND monetary_score >= 2
            THEN 'Potential Loyalists'

        WHEN recency_score <= 2
             AND frequency_score >= 3
             AND monetary_score >= 3
            THEN 'At Risk'

        WHEN recency_score <= 2
             AND frequency_score <= 2
             AND monetary_score <= 2
            THEN 'Hibernating'

        ELSE 'Others'

    END AS customer_segment

FROM `e-commerce-retention-analysis.ecommerce_retention.customer_rfm_final`;


-- ============================================================
-- SEGMENT PERFORMANCE
-- ============================================================

SELECT
    customer_segment,
    COUNT(*) AS customers,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage,

    ROUND(SUM(monetary), 2) AS segment_revenue,

    ROUND(
        SUM(monetary)
        * 100.0
        / SUM(SUM(monetary)) OVER (),
        2
    ) AS revenue_percentage,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_customer_revenue

FROM `e-commerce-retention-analysis.ecommerce_retention.customer_segments`

GROUP BY customer_segment

ORDER BY segment_revenue DESC;