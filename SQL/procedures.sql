USE ecommerce_db;

-- Procedure: Get orders placed by a specific user
CREATE PROCEDURE GetUserOrders(IN p_user_id INT)
BEGIN
    SELECT o.order_id, o.order_date, p.name AS product_name, oi.quantity
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.user_id = p_user_id;
END;

-- Procedure: Insert a new user into users table
CREATE PROCEDURE InsertUser(
    IN p_name VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(100)
)
BEGIN
    INSERT INTO users (name, email, password)
    VALUES (p_name, p_email, p_password);
END;

-- Procedure: Delete a user data from tables
CREATE PROCEDURE DeleteUser(IN p_user_id INT)
BEGIN
    -- Check if user exists
    IF EXISTS (SELECT 1 FROM users WHERE user_id = p_user_id) THEN
        
        -- First delete user-related data (if needed)
        DELETE FROM payments WHERE order_id IN (
            SELECT order_id FROM orders WHERE user_id = p_user_id
        );
        DELETE FROM order_items WHERE order_id IN (
            SELECT order_id FROM orders WHERE user_id = p_user_id
        );
        DELETE FROM orders WHERE user_id = p_user_id;
        
        -- Now delete the user
        DELETE FROM users WHERE user_id = p_user_id;
        
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User does not exist.';
    END IF;
END;

-- Procedure: Calculate total amount spent by a specific user
CREATE PROCEDURE GetUserTotalSpending(IN p_user_id INT)
BEGIN
    SELECT u.name, SUM(pay.amount) AS total_spent
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN payments pay ON o.order_id = pay.order_id
    WHERE u.user_id = p_user_id AND pay.status = 'Completed'
    GROUP BY u.name;
END;

-- Procedure: Check payment status of a specific order
CREATE PROCEDURE GetPaymentStatus(IN p_order_id INT)
BEGIN
    SELECT p.status
    FROM payments p
    WHERE p.order_id = p_order_id;
END;

-- Procedure: List all products with stock below a given threshold
CREATE PROCEDURE GetLowStockProducts(IN p_threshold INT)
BEGIN
    SELECT name, stock
    FROM products
    WHERE stock < p_threshold;
END;

-- Procedure: Update stock quantity of a product
CREATE PROCEDURE UpdateProductStock(
    IN p_product_id INT,
    IN p_new_stock INT
)
BEGIN
    UPDATE products
    SET stock = p_new_stock
    WHERE product_id = p_product_id;
END;

-- Procedure: Cancel an order and update payment status
CREATE PROCEDURE CancelOrder(IN p_order_id INT)
BEGIN
    DELETE FROM order_items WHERE order_id = p_order_id;
    DELETE FROM orders WHERE order_id = p_order_id;
    UPDATE payments SET status = 'Failed' WHERE order_id = p_order_id;
END;


-- Procedure: Return total quantity sold for each product
CREATE PROCEDURE GetProductSales()
BEGIN
    SELECT p.name, SUM(oi.quantity) AS total_sold
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.name
    ORDER BY total_sold DESC;
END;

-- Resetting delimiter back to semicolon for normal queries


