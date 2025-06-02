CREATE DATABASE ecommerce_db;
USE ecommerce_db;
SELECT DATABASE();
CREATE TABLE users(
user_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) NOT NULL UNIQUE,
password VARCHAR(100) NOT NULL
);
CREATE TABLE products(
product_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
price DECIMAL(10,2) NOT NULL,
stock INT NOT NULL
);
CREATE TABLE orders(
order_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
order_date DATE NOT NULL,
FOREIGN KEY(user_id) REFERENCES users(user_id)
);
CREATE TABLE order_items(
order_item_id INT AUTO_INCREMENT PRIMARY KEY,
order_id INT NOT NULL,
product_id INT NOT NULL,
quantity INT NOT NULL,
FOREIGN KEY(order_id) REFERENCES orders(order_id),
FOREIGN KEY(product_id) REFERENCES products(product_id)
);
CREATE TABLE payments(
payment_id INT AUTO_INCREMENT PRIMARY KEY,
order_id INT NOT NULL,
amount DECIMAL(10,2) NOT NULL,
status ENUM('Pending','Completed','Failed') DEFAULT 'Pending',
FOREIGN KEY(order_id) REFERENCES orders(order_id)
);
