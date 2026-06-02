-- ============================================================
--   ASSIGNMENT 05 — INDEXES, VIEWS & WINDOW FUNCTIONS
--   Database  : BikeStores
-- ============================================================


-- ============================================================
--  SECTION A — INDEXES
-- ============================================================

-- Q1.
-- Index for searching products by brand_id

CREATE NONCLUSTERED INDEX IX_products_brand_id
ON production.products (brand_id);

-- Test Query

SELECT
    product_id,
    product_name,
    list_price
FROM production.products
WHERE brand_id = 3;



-- Q2.
-- Index for filtering orders by order_date

CREATE NONCLUSTERED INDEX IX_orders_order_date
ON sales.orders (order_date);

-- Test Query

SELECT
    order_id,
    customer_id,
    order_date
FROM sales.orders
WHERE order_date BETWEEN '2018-01-01' AND '2018-06-30';



-- ============================================================
--  SECTION B — VIEWS
-- ============================================================

-- Q3.
-- View for Pending and Processing Orders

CREATE VIEW sales.vw_OrderFollowUp
AS
SELECT
    o.order_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    c.phone,
    c.email,
    o.order_date,
    CASE o.order_status
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Processing'
    END AS order_status
FROM sales.orders o
INNER JOIN sales.customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status IN (1,2);
GO

-- Query View

SELECT *
FROM sales.vw_OrderFollowUp;



-- Q4.
-- Inventory Monitoring View

CREATE VIEW production.vw_InventoryStatus
AS
SELECT
    s.store_name,
    p.product_name,
    b.brand_name,
    c.category_name,
    st.quantity
FROM production.stocks st
INNER JOIN sales.stores s
    ON st.store_id = s.store_id
INNER JOIN production.products p
    ON st.product_id = p.product_id
INNER JOIN production.brands b
    ON p.brand_id = b.brand_id
INNER JOIN production.categories c
    ON p.category_id = c.category_id;
GO

-- Products with less than 3 units

SELECT *
FROM production.vw_InventoryStatus
WHERE quantity < 3;



-- ============================================================
--  SECTION C — ROW_NUMBER, RANK & DENSE_RANK
-- ============================================================

-- Q5.
-- Top 2 best-selling products per store

WITH ProductSales AS
(
    SELECT
        o.store_id,
        oi.product_id,
        SUM(oi.quantity) AS total_quantity,
        RANK() OVER
        (
            PARTITION BY o.store_id
            ORDER BY SUM(oi.quantity) DESC
        ) AS sales_rank
    FROM sales.orders o
    INNER JOIN sales.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.store_id,
        oi.product_id
)
SELECT
    store_id,
    product_id,
    total_quantity,
    sales_rank
FROM ProductSales
WHERE sales_rank <= 2
ORDER BY store_id, sales_rank;



-- Q6.
-- 2nd most expensive product in each category

WITH ProductRanks AS
(
    SELECT
        category_id,
        product_name,
        list_price,
        DENSE_RANK() OVER
        (
            PARTITION BY category_id
            ORDER BY list_price DESC
        ) AS price_rank
    FROM production.products
)
SELECT
    category_id,
    product_name,
    list_price,
    price_rank
FROM ProductRanks
WHERE price_rank = 2
ORDER BY category_id;



-- Q7.
-- Find duplicate customer records

WITH DuplicateRows AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY first_name, last_name, phone
            ORDER BY customer_id
        ) AS row_num
    FROM test_customers
)
SELECT
    customer_id,
    first_name,
    last_name,
    phone,
    city
FROM DuplicateRows
WHERE row_num > 1;



-- ============================================================
--  SECTION D — LAG, LEAD & COALESCE
-- ============================================================

-- Q8.
-- Monthly Revenue Comparison for 2017

WITH MonthlySales AS
(
    SELECT
        MONTH(o.order_date) AS sales_month,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS net_sales
    FROM sales.orders o
    INNER JOIN sales.order_items oi
        ON o.order_id = oi.order_id
    WHERE YEAR(o.order_date) = 2017
    GROUP BY MONTH(o.order_date)
)
SELECT
    sales_month,
    net_sales,
    LAG(net_sales) OVER (ORDER BY sales_month) AS previous_month_sales,
    net_sales -
    LAG(net_sales) OVER (ORDER BY sales_month) AS difference
FROM MonthlySales
ORDER BY sales_month;



-- Q9.
-- Compare product price with next cheaper product
-- in the same category

SELECT
    category_id,
    product_name,
    list_price,
    LEAD(list_price) OVER
    (
        PARTITION BY category_id
        ORDER BY list_price DESC
    ) AS next_lower_price
FROM production.products
ORDER BY category_id, list_price DESC;



-- Q10.
-- Replace missing phone with email.
-- If both missing, show 'No Contact Info'

SELECT
    first_name + ' ' + last_name AS full_name,
    COALESCE(phone, email, 'No Contact Info') AS phone,
    email
FROM sales.customers
ORDER BY
    last_name,
    first_name;



-- ============================================================
--  END OF ASSIGNMENT 05
-- ============================================================
