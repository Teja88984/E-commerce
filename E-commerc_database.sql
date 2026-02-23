-- Database Schema for E-commerce

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2),
    status ENUM('completed', 'pending', 'failed'),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    customer_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_id, customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE address_changes (
    change_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    old_address TEXT,
    new_address TEXT,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE archived_orders (
    archived_order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    archived_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Sample Data Insertion

-- Inserting 20 customers
INSERT INTO customers (name, email, phone) VALUES
('John Doe', 'johndoe@example.com', '1234567890'),
('Jane Smith', 'janesmith@example.com', '0987654321'),
('Alice Johnson', 'alicej@example.com', '2345678901'),
('Bob Brown', 'bobb@example.com', '3456789012'),
('Charlie Black', 'charlieb@example.com', '4567890123'),
('David White', 'davidw@example.com', '5678901234'),
('Eva Green', 'evag@example.com', '6789012345'),
('Frank Red', 'frankr@example.com', '7890123456'),
('Grace Blue', 'graceb@example.com', '8901234567'),
('Hank Yellow', 'hanky@example.com', '9012345678'),
('Ivy Violet', 'ivyv@example.com', '0123456789'),
('Jack Pink', 'jackp@example.com', '1234567890'),
('Kelly Cyan', 'kellyc@example.com', '2345678901'),
('Leo Orange', 'leo@example.com', '3456789012'),
('Mia Magenta', 'mia@example.com', '4567890123'),
('Nina Indigo', 'nina@example.com', '5678901234'),
('Oscar Gray', 'oscar@example.com', '6789012345'),
('Paul Silver', 'paul@example.com', '7890123456'),
('Quinn Gold', 'quinn@example.com', '8901234567'),
('Ray Bronze', 'ray@example.com', '9012345678');

-- Inserting 25 products
INSERT INTO products (name, description, price, stock) VALUES
('Product 1', 'Description for product 1', 10.00, 100),
('Product 2', 'Description for product 2', 15.00, 50),
('Product 3', 'Description for product 3', 8.50, 80),
('Product 4', 'Description for product 4', 20.00, 30),
('Product 5', 'Description for product 5', 9.99, 60),
('Product 6', 'Description for product 6', 40.00, 10),
('Product 7', 'Description for product 7', 12.50, 120),
('Product 8', 'Description for product 8', 22.00, 25),
('Product 9', 'Description for product 9', 7.50, 150),
('Product 10', 'Description for product 10', 18.00, 40),
('Product 11', 'Description for product 11', 11.00, 70),
('Product 12', 'Description for product 12', 14.00, 90),
('Product 13', 'Description for product 13', 13.00, 85),
('Product 14', 'Description for product 14', 25.00, 33),
('Product 15', 'Description for product 15', 10.50, 75),
('Product 16', 'Description for product 16', 30.00, 15),
('Product 17', 'Description for product 17', 16.00, 55),
('Product 18', 'Description for product 18', 17.50, 45),
('Product 19', 'Description for product 19', 19.00, 20),
('Product 20', 'Description for product 20', 21.00, 35),
('Product 21', 'Description for product 21', 23.00, 20),
('Product 22', 'Description for product 22', 26.00, 10),
('Product 23', 'Description for product 23', 27.00, 5),
('Product 24', 'Description for product 24', 28.00, 43),
('Product 25', 'Description for product 25', 29.00, 60);

-- Inserting 50 orders
INSERT INTO orders (customer_id, total) VALUES
(1, 200.00),
(2, 150.00),
(3, 300.00),
(4, 120.00),
(5, 90.00),
(1, 250.00),
(2, 220.00),
(3, 180.00),
(4, 330.00),
(5, 450.00),
(1, 50.00),
(2, 170.00),
(3, 240.00),
(4, 40.00),
(5, 60.00),
(1, 80.00),
(2, 190.00),
(3, 300.00),
(4, 120.00),
(5, 330.00),
(1, 150.00),
(2, 180.00),
(3, 240.00),
(4, 300.00),
(5, 600.00),
(1, 400.00),
(2, 100.00),
(3, 200.00),
(4, 350.00),
(5, 75.00),
(1, 250.00),
(2, 620.00),
(3, 140.00),
(4, 330.00),
(5, 90.00);

-- Inserting 50 payments
INSERT INTO payments (order_id, amount, status) VALUES
(1, 200.00, 'completed'),
(2, 150.00, 'pending'),
(3, 300.00, 'completed'),
(4, 120.00, 'failed'),
(5, 90.00, 'completed'),
(6, 250.00, 'completed'),
(7, 220.00, 'pending'),
(8, 180.00, 'completed'),
(9, 330.00, 'completed'),
(10, 450.00, 'failed'),
(11, 50.00, 'completed'),
(12, 170.00, 'pending'),
(13, 240.00, 'completed'),
(14, 40.00, 'completed'),
(15, 60.00, 'completed'),
(16, 80.00, 'completed'),
(17, 190.00, 'completed'),
(18, 300.00, 'pending'),
(19, 120.00, 'completed'),
(20, 330.00, 'completed'),
(21, 150.00, 'completed'),
(22, 180.00, 'failed'),
(23, 240.00, 'completed'),
(24, 300.00, 'pending'),
(25, 600.00, 'completed'),
(26, 400.00, 'completed'),
(27, 100.00, 'completed'),
(28, 200.00, 'pending'),
(29, 350.00, 'completed'),
(30, 75.00, 'completed'),
(31, 250.00, 'pending'),
(32, 620.00, 'completed'),
(33, 140.00, 'completed'),
(34, 330.00, 'pending'),
(35, 90.00, 'completed');

-- Inserting 60 reviews
INSERT INTO reviews (product_id, customer_id, rating, comment) VALUES
(1, 1, 5, 'Excellent product!'),
(2, 2, 4, 'Very good!'),
(3, 3, 3, 'It was okay!'),
(4, 4, 5, 'Absolutely loved it!'),
(5, 5, 2, 'Not as expected!'),
(1, 6, 5, 'Top-notch quality!'),
(2, 7, 4, 'Pretty good!'),
(3, 8, 3, 'Average piece!'),
(4, 9, 5, 'Highly recommend!'),
(5, 10, 1, 'Disappointing!'),
(1, 11, 5, 'Best product ever!'),
(2, 12, 4, 'Really nice!'),
(3, 13, 3, 'Okay product!'),
(4, 14, 5, 'Fantastic item!'),
(5, 15, 2, 'Wouldn’t buy again!'),
(1, 16, 5, 'Extremely satisfied!'),
(2, 17, 4, 'Really good!'),
(3, 18, 3, 'Just average!'),
(4, 19, 5, 'Loved it completely!'),
(5, 20, 1, 'Very unsatisfied!'),
(1, 1, 5, 'Impressive!'),
(2, 2, 4, 'Solid product!'),
(3, 3, 3, 'Just fine!'),
(1, 4, 5, 'This is a must-have!'),
(2, 5, 2, 'Not great!'),
(4, 6, 5, 'Incredible quality!'),
(5, 7, 4, 'Decent!'),
(6, 8, 3, 'Meh!'),
(7, 9, 5, 'Absolutely perfect!'),
(8, 10, 1, 'Did not meet standards!'),
(1, 11, 5, 'Exceeds expectations!'),
(2, 12, 4, 'Very effective!'),
(3, 13, 3, 'Okay!'),
(4, 14, 5, 'Best decision ever!'),
(5, 15, 2, 'Quite disappointed!'),
(1, 16, 5, 'Amazing quality!'),
(2, 17, 4, 'Good purchase!'),
(3, 18, 3, 'I’m neutral!');

-- Triggers for various events

DELIMITER $$
CREATE TRIGGER loyalty_points AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO loyalty_points (customer_id, points)
    VALUES (NEW.customer_id, NEW.total * 0.1);
END $$

CREATE TRIGGER stock_alerts AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF NEW.stock < 10 THEN
        INSERT INTO alerts (product_id, message)
        VALUES (NEW.product_id, 'Stock is low!');
    END IF;
END $$

CREATE TRIGGER auto_discounts BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.total > 100 THEN
        SET NEW.total = NEW.total * 0.9; -- 10% discount
    END IF;
END $$

CREATE TRIGGER purchase_frequency AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    UPDATE customers SET purchase_count = purchase_count + 1 WHERE customer_id = NEW.customer_id;
END $$

CREATE TRIGGER order_archiving AFTER DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO archived_orders (order_id) VALUES (OLD.order_id);
END $$

CREATE TRIGGER payment_validation BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid payment amount';
    END IF;
END $$

CREATE TRIGGER duplicate_review_prevention BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT * FROM reviews WHERE product_id = NEW.product_id AND customer_id = NEW.customer_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duplicate review not allowed';
    END IF;
END $$

CREATE TRIGGER product_ratings AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    UPDATE products SET rating = (SELECT AVG(rating) FROM reviews WHERE product_id = NEW.product_id) WHERE product_id = NEW.product_id;
END $$

CREATE TRIGGER address_logging AFTER UPDATE ON customers
FOR EACH ROW
BEGIN
    INSERT INTO address_changes (customer_id, old_address, new_address) VALUES (OLD.customer_id, OLD.address, NEW.address);
END $$

CREATE TRIGGER order_cancellation_rules BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.status = 'cancelled' THEN
        INSERT INTO cancelled_orders (order_id, cancellation_date) VALUES (OLD.order_id, NOW());
    END IF;
END $$
DELIMITER ;