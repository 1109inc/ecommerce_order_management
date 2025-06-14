# E-commerce Order Management System

## Description
This project is a SQL-based e-commerce order management system. It provides a relational database schema to manage users, products, orders, payments, and related operations. The system includes features for tracking inventory, processing orders, managing user data, and logging important events.

## Features
- **User Management:** Create, manage, and delete user accounts. User deletions are logged.
- **Product Management:** Add and manage products, including details like name, price, and stock levels.
- **Order Processing:** Create and manage customer orders.
- **Payment Tracking:** Record and track payment status for orders (Pending, Completed, Failed).
- **Inventory Control:**
    - Automatically decreases product stock when an order is placed.
    - Prevents orders if the requested quantity exceeds available stock.
- **Data Integrity and Logging:**
    - Logs new order placements.
    - Logs user deletions.
    - Triggers to ensure data consistency (e.g., auto-completing payments if the full amount is paid).
- **Stored Procedures:** A suite of procedures for common operations, such as:
    - Retrieving orders for a specific user.
    - Calculating total spending for a user.
    - Checking payment status.
    - Listing low-stock products.
    - Updating product stock.
    - Cancelling orders.
    - Getting product sales summaries.
- **Views:** Pre-defined views for easy querying of summarized data, including:
    - User order summaries (total orders, total spent).
    - Product sales summaries (quantity sold, revenue).
    - Orders with payment status.
    - Low stock products.
    - Detailed order items.
- **Advanced SQL Queries:** Includes examples of various SQL queries, including joins, aggregations, subqueries, and window functions for reporting and analysis.
- **Indexing:** Demonstrates the use of indexes to improve query performance.

## Database Schema
The database `ecommerce_db` consists of the following tables:

-   **`users`**: Stores user information.
    -   `user_id`: Primary Key, auto-incrementing integer.
    -   `name`: Name of the user (VARCHAR).
    -   `email`: Email of the user (VARCHAR, unique).
    -   `password`: User's password (VARCHAR).
-   **`products`**: Stores product information.
    -   `product_id`: Primary Key, auto-incrementing integer.
    -   `name`: Name of the product (VARCHAR).
    -   `price`: Price of the product (DECIMAL).
    -   `stock`: Available stock quantity (INTEGER).
-   **`orders`**: Stores order information.
    -   `order_id`: Primary Key, auto-incrementing integer.
    -   `user_id`: Foreign Key referencing `users(user_id)`.
    -   `order_date`: Date the order was placed (DATE).
-   **`order_items`**: Stores details of items within an order.
    -   `order_item_id`: Primary Key, auto-incrementing integer.
    -   `order_id`: Foreign Key referencing `orders(order_id)`.
    -   `product_id`: Foreign Key referencing `products(product_id)`.
    -   `quantity`: Quantity of the product ordered (INTEGER).
-   **`payments`**: Stores payment information for orders.
    -   `payment_id`: Primary Key, auto-incrementing integer.
    -   `order_id`: Foreign Key referencing `orders(order_id)`.
    -   `amount`: Payment amount (DECIMAL).
    -   `status`: Payment status (ENUM: 'Pending', 'Completed', 'Failed').
-   **`deleted_users_log`**: Logs information about deleted users.
    -   `log_id`: Primary Key, auto-incrementing integer.
    -   `user_id`: ID of the deleted user (INTEGER).
    -   `name`: Name of the deleted user (VARCHAR).
    -   `email`: Email of the deleted user (VARCHAR).
    -   `deleted_at`: Timestamp of when the user was deleted (TIMESTAMP).
-   **`order_log`**: Logs new order entries.
    -   `log_id`: Primary Key, auto-incrementing integer.
    -   `order_id`: ID of the order (INTEGER).
    -   `user_id`: ID of the user who placed the order (INTEGER).
    -   `log_time`: Timestamp of when the order was logged (TIMESTAMP).

Key relationships:
-   A `user` can have multiple `orders`.
-   An `order` belongs to one `user`.
-   An `order` can have multiple `order_items`.
-   Each `order_item` links an `order` to a `product`.
-   An `order` can have multiple `payments` (though typically one).

Triggers are used to automate actions like updating stock levels and logging deletions.
Views are provided for aggregated data insights.

## Getting Started

### Prerequisites
-   **MySQL Server**: Ensure you have MySQL Server installed and running. You can download it from [dev.mysql.com/downloads/](https://dev.mysql.com/downloads/).
-   **MySQL Client**: A MySQL client tool, such as the MySQL command-line client, MySQL Workbench, or DBeaver, to interact with the database.

### Installation
1.  **Clone the repository (if applicable):**
    ```bash
    git clone <repository_url>
    cd <repository_directory>
    ```
    (If you have downloaded the files directly, navigate to the directory containing the SQL files.)

2.  **Connect to your MySQL server:**
    Open your MySQL client and connect to your MySQL server. You might need to provide credentials (username and password).

3.  **Create and populate the database:**
    Execute the following SQL scripts in order. You can typically run these scripts by opening them in your MySQL client and executing their content.

    a.  **Create the database schema:**
        This script creates the `ecommerce_db` database and all necessary tables.
        ```sql
        -- In your MySQL client, run the contents of:
        -- SQL/schema.sql
        ```
        *Alternatively, from the command line (ensure you are in the `SQL` directory or provide the full path):*
        ```bash
        mysql -u your_username -p < schema.sql
        ```
        *(You will be prompted for your MySQL password.)*

    b.  **Insert initial data:**
        This script populates the tables with sample data.
        ```sql
        -- In your MySQL client, run the contents of:
        -- SQL/insert_data.sql
        ```
        *Alternatively, from the command line:*
        ```bash
        mysql -u your_username -p ecommerce_db < insert_data.sql
        ```

    c.  **Create stored procedures, triggers, and views:**
        Run the following scripts to add these functionalities (stored procedures, triggers, and views) to the database. It's important to run these after the schema and initial data are set up.
        ```sql
        -- In your MySQL client, run the contents of:
        -- SQL/procedures.sql
        -- SQL/triggers.sql
        -- SQL/views.sql
        ```
        *Alternatively, from the command line (ensure you are in the `SQL` directory or provide the full path for each file):*
        ```bash
        mysql -u your_username -p ecommerce_db < procedures.sql
        mysql -u your_username -p ecommerce_db < triggers.sql
        mysql -u your_username -p ecommerce_db < views.sql
        ```

4.  **Verify the installation:**
    You can run some simple queries to ensure everything is set up correctly. For example:
    ```sql
    USE ecommerce_db;
    SELECT * FROM users;
    SELECT * FROM products;
    CALL GetUserOrders(1); -- Assuming user_id 1 exists from insert_data.sql
    ```

## Usage
Once the database is set up and populated, you can interact with it using SQL queries through your MySQL client.

**Connect to the database:**
```sql
USE ecommerce_db;
```

**Examples:**

1.  **View all products:**
    ```sql
    SELECT * FROM products;
    ```

2.  **View all orders with user names:**
    ```sql
    SELECT o.order_id, u.name AS customer_name, o.order_date
    FROM orders o
    JOIN users u ON o.user_id = u.user_id;
    ```

3.  **Get orders for a specific user (using a stored procedure):**
    Replace `1` with the desired `user_id`.
    ```sql
    CALL GetUserOrders(1);
    ```

4.  **Find products with low stock (using a stored procedure):**
    This example finds products with stock less than 5.
    ```sql
    CALL GetLowStockProducts(5);
    ```

5.  **View product sales summary (using a view):**
    ```sql
    SELECT * FROM ProductSalesSummary;
    ```

6.  **Insert a new user (using a stored procedure):**
    ```sql
    CALL InsertUser('John Doe', 'john.doe@example.com', 'securepassword123');
    SELECT * FROM users WHERE email = 'john.doe@example.com';
    ```

7.  **Show payments that are still pending:**
    ```sql
    SELECT * FROM payments WHERE status = 'Pending';
    ```

The `SQL/` directory contains more examples:
-   `SQL/queries.sql`: Contains various SELECT queries for data retrieval and analysis.
-   `SQL/procedures.sql`: Defines stored procedures for common operations.
-   `SQL/views.sql`: Defines views for accessing summarized data.
-   `SQL/test_procedures.sql`: Contains examples of how to call and test the stored procedures.

Refer to these files for more detailed examples and to understand the full capabilities of the database.

## Contributing
Contributions to this project are welcome. If you find any issues or have suggestions for improvements, please feel free to:
1.  Fork the repository.
2.  Create a new branch for your feature or bug fix.
3.  Make your changes.
4.  Test your changes thoroughly.
5.  Submit a pull request with a clear description of your changes.

Please ensure your code adheres to any existing style guidelines and that you update documentation as appropriate.