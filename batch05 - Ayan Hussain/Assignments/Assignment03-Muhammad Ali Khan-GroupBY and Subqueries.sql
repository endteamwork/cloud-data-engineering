-- ============================================================
--   ASSIGNMENT 03 — GROUP BY, HAVING & SUBQUERIES
--   Database  : BikeStores
-- ============================================================


-- ============================================================
--  SECTION A — GROUP BY & AGGREGATE FUNCTIONS
-- ============================================================

-- Q1.
-- Count the total number of orders placed by each customer.
-- Show customer_id and order_count.
-- Sort by order_count descending.

SELECT
    customer_id,
    COUNT(order_id) AS order_count
FROM sales.orders
GROUP BY customer_id
ORDER BY order_count DESC;



-- Q2.
-- For each store, find the total number of orders placed.
-- Show store_id and total_orders.

SELECT
    store_id,
    COUNT(order_id) AS total_orders
FROM sales.orders
GROUP BY store_id;



-- Q3.
-- Calculate the net revenue per order.
-- Net revenue formula:
-- SUM(quantity * list_price * (1 - discount))

SELECT
    order_id,
    SUM(quantity * list_price * (1 - discount)) AS net_revenue
FROM sales.order_items
GROUP BY order_id



-- Q4.
-- Find the average list price of products in each category.
-- Show category_id and avg_price rounded to 2 decimals.

SELECT
    category_id,
    ROUND(AVG(list_price), 2) AS avg_price
FROM production.products
GROUP BY category_id;



-- Q5.
-- Find the total number of orders placed in each year.

SELECT
    YEAR(order_date) AS order_year,
    COUNT(order_id) AS total_orders
FROM sales.orders
GROUP BY YEAR(order_date)
ORDER BY order_year ASC;



-- ============================================================
--  SECTION B — HAVING CLAUSE
-- ============================================================

-- Q6.
-- Find customers who have placed MORE than 5 orders.

SELECT
    customer_id,
    COUNT(order_id) AS order_count
FROM sales.orders
GROUP BY customer_id
HAVING COUNT(order_id) > 5;



-- Q7.
-- Find categories where average list price > 1500.

SELECT
    category_id,
    ROUND(AVG(list_price), 2) AS avg_price
FROM production.products
GROUP BY category_id
HAVING AVG(list_price) > 1500;



-- Q8.
-- Find customers who placed at least 2 orders in 2017.

SELECT
    customer_id,
    YEAR(order_date) AS order_year,
    COUNT(order_id) AS order_count
FROM sales.orders
WHERE YEAR(order_date) = 2017
GROUP BY customer_id, YEAR(order_date)
HAVING COUNT(order_id) >= 2;



-- ============================================================
--  SECTION C — SUBQUERIES
-- ============================================================

-- Q9.
-- Find all orders placed by customers who live in Houston.

SELECT *
FROM sales.orders
WHERE customer_id IN
(
    SELECT customer_id
    FROM sales.customers
    WHERE city = 'Houston'
);



-- Q10.
-- Find products whose list price is greater than average price.

SELECT
    product_name,
    list_price
FROM production.products
WHERE list_price >
(
    SELECT AVG(list_price)
    FROM production.products
);



-- Q11.
-- Find products belonging to Mountain Bikes or Road Bikes.

SELECT
    product_name,
    list_price
FROM production.products
WHERE category_id IN
(
    SELECT category_id
    FROM production.categories
    WHERE category_name IN ('Mountain Bikes', 'Road Bikes')
);



-- Q12.
-- Find customers who never placed an order.

SELECT
    customer_id,
    first_name,
    last_name
FROM sales.customers
WHERE customer_id NOT IN
(
    SELECT customer_id
    FROM sales.orders
);



-- ============================================================
--  SECTION D — JOINs WITH GROUP BY
-- ============================================================

-- Q13.
-- Find total number of orders per city.

SELECT
    c.city,
    COUNT(o.order_id) AS total_orders
FROM sales.customers c
INNER JOIN sales.orders o
    ON c.customer_id = o.customer_id
GROUP BY c.city



-- Q14.
-- Count orders handled by each staff member.

SELECT
    s.first_name + ' ' + s.last_name AS staff_name,
    COUNT(o.order_id) AS order_count
FROM sales.staffs s
INNER JOIN sales.orders o
    ON s.staff_id = o.staff_id
GROUP BY s.first_name, s.last_name;


-- Q15. BONUS
-- Find customers who spent more than $10,000.

SELECT
    c.first_name + ' ' + c.last_name AS customer_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
FROM sales.customers c
INNER JOIN sales.orders o
    ON c.customer_id = o.customer_id
INNER JOIN sales.order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.first_name, c.last_name
HAVING SUM(oi.quantity * oi.list_price * (1 - oi.discount)) > 10000;


-- ============================================================
--  END OF ASSIGNMENT 03
-- ============================================================
