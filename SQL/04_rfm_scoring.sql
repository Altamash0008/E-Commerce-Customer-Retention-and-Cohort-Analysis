-- ============================================================
-- 04 - RFM SCORING
-- ============================================================

-- SOURCE:
-- customer_rfm

-- OUTPUT:
-- customer_rfm_scored
-- customer_rfm_final


CREATE OR REPLACE TABLE
`e-commerce-retention-analysis.ecommerce_retention.customer_rfm_scored`
AS

SELECT
    *,

    NTILE(5) OVER (
        ORDER BY recency DESC
    ) AS recency_score,

    NTILE(5) OVER (
        ORDER BY frequency ASC
    ) AS frequency_score,

    NTILE(5) OVER (
        ORDER BY monetary ASC
    ) AS monetary_score

FROM `e-commerce-retention-analysis.ecommerce_retention.customer_rfm`;


-- ============================================================
-- FINAL RFM SCORE
-- ============================================================

CREATE OR REPLACE TABLE
`e-commerce-retention-analysis.ecommerce_retention.customer_rfm_final`
AS

SELECT
    Customer_ID,
    recency,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,

    CONCAT(
        CAST(recency_score AS STRING),
        CAST(frequency_score AS STRING),
        CAST(monetary_score AS STRING)
    ) AS RFM_score,

    recency_score
        + frequency_score
        + monetary_score AS RFM_total

FROM `e-commerce-retention-analysis.ecommerce_retention.customer_rfm_scored`;


-- ============================================================
-- RFM VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS customers,
    MIN(rfm_total) AS min_rfm_total,
    MAX(rfm_total) AS max_rfm_total,
    ROUND(AVG(rfm_total), 2) AS avg_rfm_total,

    COUNTIF(rfm_score IS NULL)
        AS missing_rfm_score,

    COUNTIF(rfm_total IS NULL)
        AS missing_rfm_total

FROM `e-commerce-retention-analysis.ecommerce_retention.customer_rfm_final`;