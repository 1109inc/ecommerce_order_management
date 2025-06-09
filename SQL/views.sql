USE ecommerce_db;

-- 1. View: Summary of user orders with total spent and order count
CREATE OR REPLACE VIEW UserOrderSummary AS
SELECT 
    u.user_id,
    u.name,
    u.email,
    COUNT(o.order_id) AS total_orders,
    IFNULL(SUM(pay.amount), 0) AS total_spent
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
LEFT JOIN payments pay ON o.order_id = pay.order_id AND pay.status = 'Completed'
GROUP BY u.user_id;

-- 2. View: Product sales summary (total quantity sold and revenue)
CREATE OR REPLACE VIEW ProductSalesSummary AS
SELECT 
    p.product_id,
    p.name,
    p.price,
    IFNULL(SUM(oi.quantity), 0) AS total_quantity_sold,
    IFNULL(SUM(oi.quantity * p.price), 0) AS total_revenue
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id;

-- 3. View: Orders with payment status and total amount
CREATE OR REPLACE VIEW OrderPaymentStatus AS
SELECT 
    o.order_id,
    o.user_id,
    o.order_date,
    pay.amount,
    pay.status AS payment_status
FROM orders o
LEFT JOIN payments pay ON o.order_id = pay.order_id;

-- 4. View: Low stock products (stock below threshold)
CREATE OR REPLACE VIEW LowStockProducts AS
SELECT 
    product_id,
    name,
    stock
FROM products
WHERE stock < 10;  -- You can adjust threshold here

-- 5. View: Detailed order items with product info
CREATE OR REPLACE VIEW OrderDetails AS
SELECT 
    o.order_id,
    o.user_id,
    o.order_date,
    p.product_id,
    p.name AS product_name,
    oi.quantity,
    p.price,
    (oi.quantity * p.price) AS item_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;
