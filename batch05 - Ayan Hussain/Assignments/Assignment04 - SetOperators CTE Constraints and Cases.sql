-- ============================================================
--   ASSIGNMENT 04 — SET OPERATORS, CTEs, CONSTRAINTS & CASES
--   Database  : BikeStores
-- ============================================================


-- ============================================================
--  SECTION A — SET OPERATORS
-- ============================================================

-- Q1.
-- Unified list of staff and customers (no duplicates)

SELECT
    first_name + ' ' + last_name AS full_name,
    email
FROM sales.customers

UNION

SELECT
    first_name + ' ' + last_name AS full_name,
    email
FROM sales.staffs;



-- Q2.
-- States having BOTH stores and customers

SELECT state
FROM sales.stores

INTERSECT

SELECT state
FROM sales.customers;



-- Q3.
-- Stores that received zero orders in 2018

SELECT store_id
FROM sales.stores

EXCEPT

SELECT DISTINCT store_id
FROM sales.orders
WHERE YEAR(order_date) = 2018;



-- ============================================================
--  SECTION B — CTEs
-- ============================================================

-- Q4.
-- Products priced above their category average

WITH CategoryAvg AS
(
    SELECT
        category_id,
        AVG(list_price) AS avg_price
    FROM production.products
    GROUP BY category_id
)
SELECT
    p.category_id,
    p.product_name,
    p.list_price,
    c.avg_price AS category_average
FROM production.products p
INNER JOIN CategoryAvg c
    ON p.category_id = c.category_id
WHERE p.list_price > c.avg_price
ORDER BY p.category_id, p.list_price DESC;



-- Q5.
-- Staff whose order count exceeds average order count

WITH StaffOrders AS
(
    SELECT
        staff_id,
        COUNT(*) AS order_count
    FROM sales.orders
    GROUP BY staff_id
),
AverageOrders AS
(
    SELECT AVG(CAST(order_count AS DECIMAL(10,2))) AS avg_order_count
    FROM StaffOrders
)
SELECT
    s.staff_id,
    s.order_count
FROM StaffOrders s
CROSS JOIN AverageOrders a
WHERE s.order_count > a.avg_order_count;



-- Q6.
-- Store revenue by year exceeding $1,000,000

WITH StoreRevenue AS
(
    SELECT
        o.store_id,
        YEAR(o.order_date) AS sales_year,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM sales.orders o
    INNER JOIN sales.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.store_id,
        YEAR(o.order_date)
)
SELECT
    store_id,
    sales_year,
    total_revenue
FROM StoreRevenue
WHERE total_revenue > 1000000
ORDER BY store_id, sales_year;



-- ============================================================
--  SECTION C — CONSTRAINTS (DDL)
-- ============================================================

-- Q7.
-- Loyalty Cards Table with Constraints

CREATE TABLE sales.loyalty_cards
(
    card_number INT NOT NULL PRIMARY KEY,

    customer_id INT NOT NULL,

    points INT NOT NULL
        CONSTRAINT CK_loyalty_cards_points
        CHECK (points >= 0),

    tier VARCHAR(10) NOT NULL
        CONSTRAINT CK_loyalty_cards_tier
        CHECK (tier IN ('Bronze', 'Silver', 'Gold')),

    join_date DATE NOT NULL,

    CONSTRAINT FK_loyalty_cards_customer
        FOREIGN KEY (customer_id)
        REFERENCES sales.customers(customer_id)
        ON DELETE CASCADE
);

-- Valid Inserts

INSERT INTO sales.loyalty_cards
VALUES (1001, 1, 500, 'Gold', '2024-01-15');

INSERT INTO sales.loyalty_cards
VALUES (1002, 2, 150, 'Silver', '2024-03-22');

INSERT INTO sales.loyalty_cards
VALUES (1003, 3, 0, 'Bronze', '2024-06-01');

-- Invalid Inserts (Should Fail)

INSERT INTO sales.loyalty_cards
VALUES (1001, 4, 100, 'Gold', '2024-07-01');

INSERT INTO sales.loyalty_cards
VALUES (1004, 1, -50, 'Silver', '2024-08-01');

INSERT INTO sales.loyalty_cards
VALUES (1005, 5, 200, 'Diamond', '2024-09-01');



-- Q8.
-- Prevent shipped_date before order_date

ALTER TABLE test_orders
ADD CONSTRAINT CK_test_orders_shipping_dates
CHECK
(
    shipped_date IS NULL
    OR shipped_date >= order_date
);

-- Should FAIL

INSERT INTO test_orders
VALUES (4, '2024-04-10', '2024-04-08');

-- Should PASS

INSERT INTO test_orders
VALUES (5, '2024-04-10', '2024-04-15');



-- ============================================================
--  SECTION D — CASE EXPRESSIONS
-- ============================================================

-- Q9.
-- Shipping Speed Classification

SELECT
    order_id,
    order_date,
    shipped_date,
    CASE
        WHEN shipped_date IS NULL THEN 'Pending'
        WHEN DATEDIFF(DAY, order_date, shipped_date) <= 2 THEN 'Fast'
        WHEN DATEDIFF(DAY, order_date, shipped_date) BETWEEN 3 AND 5 THEN 'Normal'
        ELSE 'Delayed'
    END AS shipping_speed
FROM sales.orders
ORDER BY order_id;



-- Q10.
-- Stock Level Classification

SELECT
    store_id,
    product_id,
    quantity,
    CASE
        WHEN quantity = 0 THEN 'Out of Stock'
        WHEN quantity BETWEEN 1 AND 10 THEN 'Low Stock'
        WHEN quantity BETWEEN 11 AND 50 THEN 'Sufficient'
        ELSE 'Well Stocked'
    END AS stock_status
FROM production.stocks
ORDER BY store_id, quantity ASC;



-- ============================================================
--  END OF ASSIGNMENT 04
-- ============================================================
