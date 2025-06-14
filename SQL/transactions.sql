USE ecommerce_db;

CREATE PROCEDURE PlaceOrderTransaction(
    IN p_user_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_paid_amount DECIMAL(10,2)
)
BEGIN
    DECLARE stock_available INT;
    DECLARE product_price DECIMAL(10,2);
    DECLARE total_cost DECIMAL(10,2);
    DECLARE order_id_created INT;

    START TRANSACTION;

    -- Lock row and get stock, price
    SELECT stock, price INTO stock_available, product_price
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;

    SET total_cost = product_price * p_quantity;

    -- Check stock
    IF stock_available < p_quantity THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock available.';
    -- Check payment
    ELSEIF p_paid_amount < total_cost THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient payment amount.';
    ELSEIF p_paid_amount > total_cost THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Overpayment detected.';
    ELSE
        -- Insert order
        INSERT INTO orders (user_id, order_date)
        VALUES (p_user_id, CURDATE());

        SET order_id_created = LAST_INSERT_ID();

        -- Insert order item
        INSERT INTO order_items (order_id, product_id, quantity)
        VALUES (order_id_created, p_product_id, p_quantity);

        -- Insert payment with status
        INSERT INTO payments (order_id, amount, status)
        VALUES (order_id_created, p_paid_amount, 'Completed');

        COMMIT;
    END IF;
END;




