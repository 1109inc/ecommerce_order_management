USE ecommerce_db;
DELIMITER //
-- Trigger: Decrease product stock after inserting into order_items
CREATE TRIGGER trg_decrease_stock_after_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;
END;
//
-- Trigger: Prevent order if requested quantity exceeds stock
CREATE TRIGGER trg_prevent_over_order
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;
    
    SELECT stock INTO available_stock
    FROM products
    WHERE product_id = NEW.product_id;
    
    IF NEW.quantity > available_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ordered quantity exceeds available stock.';
    END IF;
END;
//
-- Table for logging order insertions
CREATE TABLE order_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    user_id INT,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger: Log whenever a new order is placed
CREATE TRIGGER trg_log_new_order
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_log (order_id, user_id)
    VALUES (NEW.order_id, NEW.user_id);
END;
//
-- Trigger: Set payment status to 'Completed' if amount equals sum of order items * price
CREATE TRIGGER trg_auto_complete_payment
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
    DECLARE expected_amount DECIMAL(10,2);

    SELECT SUM(oi.quantity * p.price)
    INTO expected_amount
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    WHERE oi.order_id = NEW.order_id;

    IF NEW.amount = expected_amount THEN
        SET NEW.status = 'Completed';
    END IF;
END;
//
-- Table for user deletions log
CREATE TABLE deleted_users_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    name VARCHAR(100),
    email VARCHAR(100),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Trigger: Log user deletions
CREATE TRIGGER trg_log_user_deletion
BEFORE DELETE ON users
FOR EACH ROW
BEGIN
    INSERT INTO deleted_users_log (user_id, name, email)
    VALUES (OLD.user_id, OLD.name, OLD.email);
END;
//
DELIMITER ;
