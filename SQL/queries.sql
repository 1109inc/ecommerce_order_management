USE ecommerce_db;
-- Basic Data Retrieval

-- 1. View all users
SELECT * FROM users;

-- 2. View all products
SELECT * FROM products;

-- 3. View all orders
SELECT * FROM orders;

-- 4. View all payments
SELECT * FROM payments;

-- 5. View all order items
SELECT * FROM order_items;

-- JOIN Queries & Reporting

-- 6. Show all orders with user names
-- CREATE INDEX idx_orders_user_id ON orders(user_id); (Run this if you want to create the index)
-- DROP INDEX IF EXISTS idx_orders_user_id; (Run this if you want to drop the index))
EXPLAIN ANALYZE
SELECT o.order_id, u.name AS customer_name, o.order_date
FROM orders o
JOIN users u ON o.user_id = u.user_id;
-- Performance:
-- Before Indexing: actual time = 3.54..3.72 ms
-- After Indexing:  actual time = 0.0416..0.0489 ms
-- Improvement: ~98.7% faster
-- 7. Show full order details: order, user, and items

-- CREATE INDEX idx_order_items_order_id ON order_items(order_id);
-- CREATE INDEX idx_order_items_product_id ON order_items(product_id);
-- CREATE INDEX idx_orders_user_id ON orders(user_id);
-- CREATE INDEX idx_products_product_id ON products(product_id);
-- DROP INDEX IF EXISTS idx_order_items_order_id;
-- DROP INDEX IF EXISTS idx_order_items_product_id;
-- DROP INDEX IF EXISTS idx_orders_user_id;
-- DROP INDEX IF EXISTS idx_products_product_id;
EXPLAIN ANALYZE
SELECT 
    o.order_id,
    u.name AS customer_name,
    p.name AS product_name,
    oi.quantity,
    o.order_date
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;
-- Performance:
-- Before Indexing: actual time = 1.18..1.20 ms
-- After Indexing:  actual time = 1.31..1.34 ms
-- Observation: Slight increase in time due to index caching/warm-up or small dataset.
-- Keep index anyway for **larger datasets**, as it improves **scalability** and **efficiency** when data grows.
-- 8. Show payments with order and user details
-- CREATE INDEX idx_payments_order_id ON payments(order_id);
-- DROP INDEX IF EXISTS idx_payments_order_id;
EXPLAIN ANALYZE
SELECT 
    pay.payment_id,
    pay.amount,
    pay.status,
    u.name AS customer_name,
    o.order_date
FROM payments pay
JOIN orders o ON pay.order_id = o.order_id
JOIN users u ON o.user_id = u.user_id;
-- Performance
-- Before indexing: actual time = 0.687...0.713 ms
-- After indexing:  actual time = 0.0605...0.07 ms
-- 90.18% faster
-- Aggregation Queries

-- 9. Total revenue from all completed payments
CREATE INDEX idx_payments_status ON payments(status);
-- DROP INDEX IF EXISTS idx_payments_status;
EXPLAIN ANALYZE
SELECT SUM(amount) AS total_revenue
FROM payments
WHERE status = 'Completed';
-- Performance
-- Before Indexing: actual time = 0.288 ms
-- After Indexing:  actual time = 0.0038 ms
-- 10. Total number of orders per user
EXPLAIN ANALYZE
SELECT u.name, COUNT(o.order_id) AS total_orders
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.name;

-- 11. Most sold products (by quantity)
EXPLAIN ANALYZE 
SELECT p.name, SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.name
ORDER BY total_sold DESC;

-- Filtering & Conditional Data

-- 12. Orders placed after a certain date
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE order_date > '2024-06-01';

-- 13. Products low on stock (< 20)
EXPLAIN ANALYZE
SELECT * FROM products
WHERE stock < 20;

-- 14. Payments that are still pending
EXPLAIN ANALYZE
SELECT * FROM payments
WHERE status = 'Pending';

-- Subqueries & IN/EXISTS

-- 15. Users who made an order
EXPLAIN ANALYZE
SELECT name FROM users
WHERE user_id IN (SELECT DISTINCT user_id FROM orders);
-- Users who made an order (using EXISTS)
SELECT u.name
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.user_id = u.user_id
);

-- 16. Products that were never ordered
EXPLAIN ANALYZE
SELECT * FROM products
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM order_items);


-- Window Functions 


-- 17. Show each payment as a percentage of total payments
EXPLAIN ANALYZE
SELECT 
    order_id,
    amount,
    ROUND((amount / SUM(amount) OVER ()) * 100, 2) AS percentage_of_total
FROM payments
WHERE status = 'Completed';

-- 18. Rank users by number of orders (most to least)
SELECT 
    u.name,
    COUNT(o.order_id) AS total_orders,
    RANK() OVER (ORDER BY COUNT(o.order_id) DESC) AS user_rank
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.name;

-- 19. Running total of revenue from completed payments
EXPLAIN ANALYZE
SELECT 
    payment_id,
    order_id,
    amount,
    SUM(amount) OVER (ORDER BY payment_id) AS running_total
FROM payments
WHERE status = 'Completed';

-- Test Queries

-- 20. What are the top 2 most expensive products?
SELECT * FROM products
ORDER BY price DESC
LIMIT 2;

-- 21. Average amount paid per user
EXPLAIN ANALYZE
SELECT 
    u.name,
    ROUND(AVG(p.amount), 2) AS avg_payment
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN payments p ON o.order_id = p.order_id
WHERE p.status = 'Completed'
GROUP BY u.name;

-- 22. Product stock value (price * stock) for inventory tracking
EXPLAIN ANALYZE
SELECT 
    name AS product,
    stock,
    price,
    stock * price AS stock_value
FROM products
ORDER BY stock_value DESC;

