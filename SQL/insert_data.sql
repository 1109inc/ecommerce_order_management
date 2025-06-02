USE ecommerce_db;
SELECT DATABASE();
INSERT INTO users (name,email,password) VALUES 
('Alice', 'alice@example.com', 'alice123'),
('Bob', 'bob@example.com', 'bob123'),
('Charlie', 'charlie@example.com', 'charlie123');
INSERT INTO products (name, price, stock) VALUES
('Laptop', 70000.00, 10),
('Headphones', 2500.00, 50),
('Keyboard', 1500.00, 30),
('Smartphone', 45000.00, 20);
INSERT INTO orders (user_id, order_date) VALUES
(1, '2024-06-01'),
(2, '2024-06-02'),
(1, '2024-06-03');
INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1), -- Alice bought 1 Laptop
(1, 2, 2), -- Alice bought 2 Headphones
(2, 3, 1), -- Bob bought 1 Keyboard
(3, 4, 1); -- Alice bought 1 Smartphone
INSERT INTO payments (order_id, amount, status) VALUES
(1, 75000.00, 'Completed'),
(2, 1500.00, 'Completed'),
(3, 45000.00, 'Pending');
