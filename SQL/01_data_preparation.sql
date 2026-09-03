-- ============================================================
-- 01 - DATA PREPARATION
-- E-Commerce Customer Retention & RFM Analysis
-- ============================================================

-- PURPOSE:
-- Combine raw transaction datasets, perform data-quality checks,
-- remove invalid transactions, and create customer-order data.

-- SOURCE TABLES:
-- raw_2009-2010
-- raw_2010-2011

-- OUTPUT TABLES:
-- combined_2009-2011
-- clean_transactions
-- customer_orders


-- ============================================================
-- 1. SOURCE DATA VALIDATION
-- ============================================================

SELECT COUNT(*) AS rows_2009_2010
FROM `e-commerce-retention-analysis.ecommerce_retention.raw_2009-2010`;

SELECT COUNT(*) AS rows_2010_2011
FROM `e-commerce-retention-analysis.ecommerce_retention.raw_2010-2011`;


-- ============================================================
-- 2. COMBINE RAW DATA
-- ============================================================

CREATE OR REPLACE TABLE
`e-commerce-retention-analysis.ecommerce_retention.combined_2009-2011` AS

SELECT *
FROM `e-commerce-retention-analysis.ecommerce_retention.raw_2009-2010`

UNION ALL

SELECT *
FROM `e-commerce-retention-analysis.ecommerce_retention.raw_2010-2011`;


-- ============================================================
-- 3. DATA QUALITY CHECKS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Invoice) AS unique_invoices,
    COUNT(DISTINCT `Customer ID`) AS unique_customers,
    MIN(InvoiceDate) AS first_transaction,
    MAX(InvoiceDate) AS last_transaction
FROM `e-commerce-retention-analysis.ecommerce_retention.combined_2009-2011`;


SELECT
    COUNT(*) AS total_rows,
    COUNTIF(`Customer ID` IS NULL) AS missing_customer_id,
    COUNTIF(InvoiceDate IS NULL) AS missing_invoice_date,
    COUNTIF(Invoice IS NULL) AS missing_invoice,
    COUNTIF(Quantity IS NULL) AS missing_quantity,
    COUNTIF(Quantity <= 0) AS non_positive_quantity
FROM `e-commerce-retention-analysis.ecommerce_retention.combined_2009-2011`;


-- ============================================================
-- 4. CREATE CLEAN TRANSACTION TABLE
-- ============================================================

CREATE OR REPLACE TABLE
`e-commerce-retention-analysis.ecommerce_retention.clean_transactions` AS

SELECT
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price,
    `Customer ID` AS Customer_ID,
    Country,
    Quantity * Price AS revenue,
    DATE(InvoiceDate) AS order_date,
    DATE_TRUNC(DATE(InvoiceDate), MONTH) AS order_month

FROM `e-commerce-retention-analysis.ecommerce_retention.combined_2009-2011`

WHERE
    Quantity > 0
    AND Price > 0
    AND `Customer ID` IS NOT NULL
    AND NOT STARTS_WITH(CAST(Invoice AS STRING), 'C');


-- ============================================================
-- 5. CREATE CUSTOMER-ORDER TABLE
-- ============================================================

CREATE OR REPLACE TABLE
`e-commerce-retention-analysis.ecommerce_retention.customer_orders`
AS

SELECT
    Customer_ID AS customer_id,
    Invoice AS invoice,
    MIN(InvoiceDate) AS order_date,
    SUM(revenue) AS order_revenue,
    SUM(Quantity) AS total_items,
    COUNT(DISTINCT StockCode) AS product_lines,
    ANY_VALUE(Country) AS country

FROM `e-commerce-retention-analysis.ecommerce_retention.clean_transactions`

GROUP BY
    Customer_ID,
    Invoice;


-- ============================================================
-- 6. FINAL VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order

FROM `e-commerce-retention-analysis.ecommerce_retention.customer_orders`;