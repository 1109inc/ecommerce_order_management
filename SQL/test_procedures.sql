-- test_procedures.sql
-- This file contains test queries to verify procedures, triggers, and transactions.
-- These are for testing/demo purposes and not part of production logic.
USE ecommerce_db;
CALL GetUserOrders(1);
CALL InsertUser('David', 'dv@example.com', 'david123');
SELECT * FROM order_items;
CALL PlaceOrderTransaction(7, 2, 1,2600.00);
select * from products;
call GetUserTotalSpending(7);
call CancelOrder(7);