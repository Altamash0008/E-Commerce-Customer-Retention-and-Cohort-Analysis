SELECT COUNT(*) AS rows_2009_2010
FROM `e-commerce-retention-analysis.ecommerce_retention.raw_2009-2010`;

SELECT COUNT(*) AS rows_2010_2011
FROM `e-commerce-retention-analysis.ecommerce_retention.raw_2010-2011`;

-- Combine both tables
CREATE OR REPLACE TABLE
`e-commerce-retention-analysis.ecommerce_retention.combined_2009-2011` AS 
SELECT *
FROM `e-commerce-retention-analysis.ecommerce_retention.raw_2009-2010`

UNION ALL

SELECT *
FROM `e-commerce-retention-analysis.ecommerce_retention.raw_2010-2011`;

SELECT COUNT(*) AS total_rows
FROM `e-commerce-retention-analysis.ecommerce_retention.combined_2009-2011`;

SELECT *
FROM `e-commerce-retention-analysis.ecommerce_retention.combined_2009-2011`
LIMIT 10;