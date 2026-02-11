CREATE DATABASE ecommerce;
USE ecommerce;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(20) DEFAULT 'customer'
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL
);

CREATE TABLE cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT DEFAULT 1,
    CONSTRAINT fk_cart_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_cart_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    status VARCHAR(30) DEFAULT 'Processing',
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_item_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_item_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_method VARCHAR(50),
    payment_status VARCHAR(30),
    payment_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE otp_verification (
    otp_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_otp_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_review_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

DELIMITER $$

CREATE TRIGGER reduce_stock_after_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;
END$$

DELIMITER ;

INSERT INTO customers (name,email,password) VALUES
('Teja','teja@gmail.com','1234');

INSERT INTO products (product_name,price,stock) VALUES
('MacBook',100000,10),
('iPhone',70000,10),
('AirPods',15000,10),
('iPad',40000,10);

INSERT INTO orders (customer_id,total_amount)
VALUES (1,70000);

INSERT INTO order_items (order_id,product_id,quantity,price)
VALUES (1,2,1,70000);

INSERT INTO payments (order_id,payment_method,payment_status)
VALUES (1,'UPI','SUCCESS');

SELECT customers.name, orders.total_amount, orders.status
FROM orders
JOIN customers ON orders.customer_id = customers.customer_id;

SELECT product_name, stock FROM products;

SELECT product_name, AVG(rating) AS average_rating
FROM reviews
JOIN products ON reviews.product_id = products.product_id
GROUP BY product_name;