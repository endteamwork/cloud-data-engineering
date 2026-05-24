use BikeStores
-- ============================================================
--  ASSIGNMENT 01 — Querying, Sorting & Filtering
--  Database : BikeStores
--  Topics   : SELECT, WHERE, ORDER BY, TOP/OFFSET-FETCH,
--             DISTINCT, AND / OR
-- ============================================================


-- ============================================================
--  Question 1 — SELECT & WHERE
--  Retrieve the first name, last name, city, and phone number
--  of all customers who live in the state of 'CA' (California)
--  and have a phone number on record.
-- ============================================================

SELECT
    first_name,
    last_name,
    city,
    phone
FROM sales.customers
WHERE state = 'CA'
  AND phone IS NOT NULL;




-- ============================================================
--  Question 2 — ORDER BY (Multiple Columns)
--  Fetch the product_id, product_name, model_year, and
--  list_price of all products.
--  Sort the results by model_year in descending order, and
--  within the same year sort by list_price in ascending order.
-- ============================================================

SELECT
    product_id,
    product_name,
    model_year,
    list_price
FROM production.products
ORDER BY model_year DESC,
         list_price ASC;




-- ============================================================
--  Question 3 — TOP N & TOP PERCENT
--  a) Return the top 5 most expensive products showing only
--     product_name and list_price.
--  b) Return the top 5% of cheapest products (all columns).
-- ============================================================

-- Part a:
SELECT TOP 5
    product_name,
    list_price
FROM production.products
ORDER BY list_price DESC;


-- Part b:
SELECT TOP 5 PERCENT *
FROM production.products
ORDER BY list_price ASC;

-- Row count depends on total records in the table
-- Example: If table contains 1000 rows, result returns 50 rows




-- ============================================================
--  Question 4 — OFFSET & FETCH (Pagination)
--  The sales team wants to browse products page by page,
--  10 products per page, sorted by list_price descending.
-- ============================================================

-- Page 1 (Rows 1 - 10)
SELECT *
FROM production.products
ORDER BY list_price DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;


-- Page 2 (Rows 11 - 20)
SELECT *
FROM production.products
ORDER BY list_price DESC
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;


-- Page 3 (Rows 21 - 30)
SELECT *
FROM production.products
ORDER BY list_price DESC
OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY;




-- ============================================================
--  Question 5 — DISTINCT
-- ============================================================

-- Part a:
SELECT DISTINCT state
FROM sales.customers
ORDER BY state ASC;


-- Part b:
SELECT DISTINCT
    state,
    city
FROM sales.customers
ORDER BY state ASC,
         city ASC;


-- Part c:
SELECT COUNT(DISTINCT model_year) AS total_model_years
FROM production.products;




-- ============================================================
--  Question 6 — Logical Operators (AND / OR)
-- ============================================================

SELECT
    product_id,
    product_name,
    brand_id,
    category_id,
    list_price
FROM production.products
WHERE list_price BETWEEN 500 AND 1500
  AND (model_year = 2019 OR model_year = 2020)
ORDER BY list_price ASC;