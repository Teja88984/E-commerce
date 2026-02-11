CREATE DATABASE ecommerce;
USE ecommerce;

-- ============================================================================
-- ENUM/LOOKUP TABLES
-- ============================================================================

CREATE TABLE order_status_enum (
    status_id INT PRIMARY KEY AUTO_INCREMENT,
    status_name VARCHAR(30) UNIQUE NOT NULL,
    description VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO order_status_enum (status_name, description) VALUES
('Pending', 'Order awaiting confirmation'),
('Processing', 'Order being prepared'),
('Shipped', 'Order on the way'),
('Delivered', 'Order delivered'),
('Cancelled', 'Order cancelled'),
('Returned', 'Order returned');

CREATE TABLE payment_status_enum (
    status_id INT PRIMARY KEY AUTO_INCREMENT,
    status_name VARCHAR(30) UNIQUE NOT NULL,
    description VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO payment_status_enum (status_name, description) VALUES
('Pending', 'Payment pending'),
('Processing', 'Payment processing'),
('SUCCESS', 'Payment successful'),
('FAILED', 'Payment failed'),
('REFUNDED', 'Payment refunded');

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Accessories', 'Phone and device accessories'),
('Computers', 'Laptops and computers');

-- ============================================================================
-- MAIN TABLES
-- ============================================================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'customer',
    phone_number VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
);

CREATE TABLE customer_addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    address_type VARCHAR(20) NOT NULL COMMENT 'billing or shipping',
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'India',
    is_default BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_address_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    INDEX idx_customer_id (customer_id),
    INDEX idx_default (is_default)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    category_id INT NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories(category_id),
    CONSTRAINT check_price CHECK (price > 0),
    CONSTRAINT check_stock CHECK (stock >= 0),
    INDEX idx_product_name (product_name),
    INDEX idx_category_id (category_id),
    INDEX idx_is_active (is_active)
);

CREATE TABLE cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_cart_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_cart_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    CONSTRAINT check_quantity CHECK (quantity > 0),
    CONSTRAINT unique_customer_product UNIQUE KEY (customer_id, product_id),
    INDEX idx_customer_id (customer_id),
    INDEX idx_added_at (added_at)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    shipping_address_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    status VARCHAR(30) DEFAULT 'Pending',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_address FOREIGN KEY (shipping_address_id) REFERENCES customer_addresses(address_id),
    CONSTRAINT check_total_amount CHECK (total_amount >= 0),
    INDEX idx_customer_id (customer_id),
    INDEX idx_order_date (order_date),
    INDEX idx_status (status)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) GENERATED ALWAYS AS (quantity * price) STORED,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_item_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_item_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    CONSTRAINT check_quantity CHECK (quantity > 0),
    CONSTRAINT check_price CHECK (price > 0),
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL UNIQUE,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    transaction_id VARCHAR(100),
    payment_amount DECIMAL(12,2) NOT NULL,
    payment_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_payment_status FOREIGN KEY (payment_status) REFERENCES payment_status_enum(status_name),
    INDEX idx_order_id (order_id),
    INDEX idx_payment_status (payment_status),
    INDEX idx_payment_time (payment_time)
);

CREATE TABLE otp_verification (
    otp_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    attempts INT DEFAULT 0,
    max_attempts INT DEFAULT 3,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME,
    verified_at DATETIME,
    CONSTRAINT fk_otp_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    CONSTRAINT check_attempts CHECK (attempts <= max_attempts),
    INDEX idx_customer_verified (customer_id, verified),
    INDEX idx_expires_at (expires_at)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_review_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    CONSTRAINT check_rating CHECK (rating BETWEEN 1 AND 5),
    INDEX idx_product_id (product_id),
    INDEX idx_customer_id (customer_id),
    INDEX idx_is_active (is_active)
);

-- ============================================================================
-- AUDIT & TRACKING TABLES
-- ============================================================================

CREATE TABLE product_stock_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    old_stock INT NOT NULL,
    new_stock INT NOT NULL,
    change_quantity INT GENERATED ALWAYS AS (new_stock - old_stock) STORED,
    change_reason VARCHAR(100),
    changed_by VARCHAR(100) DEFAULT 'System',
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_product_id (product_id),
    INDEX idx_changed_at (changed_at)
);

CREATE TABLE order_status_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    old_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    changed_by VARCHAR(100) DEFAULT 'System',
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    CONSTRAINT fk_history_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_changed_at (changed_at)
);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

DELIMITER $$

-- Reduce stock after order item is added
CREATE TRIGGER reduce_stock_after_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE old_stock INT;
    
    SELECT stock INTO old_stock FROM products WHERE product_id = NEW.product_id;
    
    UPDATE products
    SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;
    
    INSERT INTO product_stock_audit (product_id, old_stock, new_stock, change_reason)
    VALUES (NEW.product_id, old_stock, old_stock - NEW.quantity, 'Order placed');
END$$

-- Restore stock when order item is deleted
CREATE TRIGGER restore_stock_on_order_cancel
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
    DECLARE old_stock INT;
    
    SELECT stock INTO old_stock FROM products WHERE product_id = OLD.product_id;
    
    UPDATE products
    SET stock = stock + OLD.quantity
    WHERE product_id = OLD.product_id;
    
    INSERT INTO product_stock_audit (product_id, old_stock, new_stock, change_reason)
    VALUES (OLD.product_id, old_stock, old_stock + OLD.quantity, 'Order cancelled');
END$$

-- Track order status changes
CREATE TRIGGER track_order_status_change
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO order_status_history (order_id, old_status, new_status)
        VALUES (NEW.order_id, OLD.status, NEW.status);
    END IF;
END$$

DELIMITER ;

-- ============================================================================
-- SAMPLE DATA
-- ============================================================================

INSERT INTO customers (name, email, password_hash, phone_number) VALUES
('Teja Kumar', 'teja@gmail.com', '$2y$10$abcdefghijklmnopqrstuvwxyz123456', '9876543210'),
('Arjun Singh', 'arjun@gmail.com', '$2y$10$abcdefghijklmnopqrstuvwxyz123456', '9876543211'),
('Priya Sharma', 'priya@gmail.com', '$2y$10$abcdefghijklmnopqrstuvwxyz123456', '9876543212');

INSERT INTO customer_addresses (customer_id, address_type, street, city, state, postal_code, is_default) VALUES
(1, 'shipping', '123 Main Street', 'Bangalore', 'Karnataka', '560001', TRUE),
(1, 'billing', '456 Secondary Street', 'Bangalore', 'Karnataka', '560002', FALSE),
(2, 'shipping', '789 Tech Park', 'Hyderabad', 'Telangana', '500081', TRUE),
(3, 'shipping', '321 Business Hub', 'Delhi', 'Delhi', '110001', TRUE);

INSERT INTO products (product_name, description, category_id, price, stock) VALUES
('MacBook Pro 14', 'Apple MacBook Pro 14-inch M2 Pro', 3, 139999.00, 10),
('iPhone 15 Pro', 'iPhone 15 Pro Max with 256GB storage', 1, 129999.00, 15),
('AirPods Pro', 'Wireless AirPods Pro with noise cancellation', 2, 24999.00, 25),
('iPad Air', 'iPad Air 5th generation 64GB', 1, 54999.00, 8),
('Apple Watch Series 9', 'Apple Watch Series 9 45mm', 2, 39999.00, 12);

INSERT INTO cart (customer_id, product_id, quantity) VALUES
(1, 2, 1),
(1, 3, 2),
(2, 4, 1);

INSERT INTO orders (customer_id, shipping_address_id, total_amount, status) VALUES
(1, 1, 129999.00, 'Processing'),
(2, 3, 54999.00, 'Pending'),
(3, 4, 54999.00, 'Delivered');

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 2, 1, 129999.00),
(2, 4, 1, 54999.00),
(3, 4, 1, 54999.00);

INSERT INTO payments (order_id, payment_method, payment_status, payment_amount) VALUES
(1, 'UPI', 'SUCCESS', 129999.00),
(2, 'Credit Card', 'Processing', 54999.00),
(3, 'Debit Card', 'SUCCESS', 54999.00);

INSERT INTO reviews (customer_id, product_id, rating, comment, is_verified_purchase) VALUES
(3, 4, 5, 'Excellent product! Great build quality.', TRUE),
(1, 3, 4, 'Good sound quality, battery life is decent.', TRUE),
(2, 4, 5, 'Perfect for my needs. Highly recommended!', TRUE);

-- ============================================================================
-- USEFUL QUERIES
-- ============================================================================

-- Customer order summary with status
SELECT 
    c.name,
    c.email,
    o.order_id,
    o.total_amount,
    o.status,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC;

-- Product inventory status
SELECT 
    p.product_id,
    p.product_name,
    cat.category_name,
    p.price,
    p.stock,
    CASE 
        WHEN p.stock = 0 THEN 'Out of Stock'
        WHEN p.stock < 5 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM products p
JOIN categories cat ON p.category_id = cat.category_id
ORDER BY p.stock ASC;

-- Product ratings and reviews
SELECT 
    p.product_name,
    COUNT(r.review_id) AS total_reviews,
    AVG(r.rating) AS average_rating,
    MIN(r.rating) AS min_rating,
    MAX(r.rating) AS max_rating
FROM reviews r
JOIN products p ON r.product_id = p.product_id
WHERE r.is_active = TRUE
GROUP BY p.product_id, p.product_name
ORDER BY average_rating DESC;

-- Order summary by customer
SELECT 
    c.customer_id,
    c.name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE c.is_active = TRUE
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;

-- Payment status overview
SELECT 
    ps.status_name,
    COUNT(p.payment_id) AS payment_count,
    SUM(p.payment_amount) AS total_amount
FROM payments p
RIGHT JOIN payment_status_enum ps ON p.payment_status = ps.status_name
GROUP BY ps.status_name
ORDER BY payment_count DESC;

-- Stock audit trail for a product
SELECT 
    p.product_name,
    psa.old_stock,
    psa.new_stock,
    psa.change_quantity,
    psa.change_reason,
    psa.changed_at
FROM product_stock_audit psa
JOIN products p ON psa.product_id = p.product_id
ORDER BY psa.changed_at DESC
LIMIT 20;