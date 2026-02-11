-- Improved E-commerce Database Schema
DROP DATABASE IF EXISTS ecommerce;
CREATE DATABASE ecommerce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce;

-- ==================== CUSTOMERS TABLE ====================
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,  -- Changed from password to password_hash (store hashed passwords)
    phone VARCHAR(15),
    address TEXT,
    role ENUM('customer', 'admin') DEFAULT 'customer',
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
);

-- ==================== PRODUCTS TABLE ====================
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock INT DEFAULT 0 CHECK (stock >= 0),
    sku VARCHAR(50) UNIQUE,  -- Stock Keeping Unit for product identification
    is_available BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_sku (sku),
    INDEX idx_is_available (is_available)
);

-- ==================== CART TABLE ====================
CREATE TABLE cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT DEFAULT 1 CHECK (quantity > 0),
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_cart_item (customer_id, product_id),  -- Prevent duplicate items in cart
    INDEX idx_customer_id (customer_id)
);

-- ==================== ORDERS TABLE ====================
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    status ENUM('Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Processing',
    delivery_address TEXT,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    INDEX idx_customer_id (customer_id),
    INDEX idx_order_date (order_date),
    INDEX idx_status (status)
);

-- ==================== ORDER_ITEMS TABLE ====================
CREATE TABLE order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),  -- Store price at time of purchase
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
);

-- ==================== PAYMENTS TABLE ====================
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,  -- One payment per order
    payment_method ENUM('Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Wallet') NOT NULL,
    payment_status ENUM('SUCCESS', 'PENDING', 'FAILED', 'REFUNDED') DEFAULT 'PENDING',
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    transaction_id VARCHAR(100) UNIQUE,  -- For tracking with payment gateway
    payment_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    INDEX idx_payment_status (payment_status),
    INDEX idx_transaction_id (transaction_id)
);

-- ==================== OTP_VERIFICATION TABLE ====================
CREATE TABLE otp_verification (
    otp_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    attempts INT DEFAULT 0,
    max_attempts INT DEFAULT 3,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME DEFAULT DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 10 MINUTE),  -- OTP expires in 10 minutes
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    INDEX idx_customer_id (customer_id),
    INDEX idx_expires_at (expires_at)
);

-- ==================== REVIEWS TABLE ====================
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    order_id INT,  -- Link review to the actual purchase
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE SET NULL,
    UNIQUE KEY unique_review (customer_id, product_id, order_id),  -- Prevent duplicate reviews
    INDEX idx_product_id (product_id),
    INDEX idx_rating (rating)
);

-- ==================== CART_HISTORY TABLE ====================
CREATE TABLE cart_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT CHECK (quantity > 0),
    action VARCHAR(20) NOT NULL DEFAULT 'add',  -- 'add', 'remove', 'update'
    action_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_customer_id (customer_id),
    INDEX idx_action_time (action_time)
);

-- ==================== SAMPLE DATA ====================

-- Insert sample customer
INSERT INTO customers (name, email, password_hash, phone, role) 
VALUES ('Teja', 'teja@gmail.com', '$2b$10$abcdef...hashed_password', '+91-XXXXXXXXXX', 'customer');

-- Insert sample products
INSERT INTO products (product_name, description, price, stock, sku, is_available) VALUES
('MacBook', 'Apple MacBook Pro 16-inch', 100000, 10, 'SKU-MACBOOK-001', TRUE),
('iPhone', 'Apple iPhone 15 Pro', 70000, 10, 'SKU-IPHONE-015', TRUE),
('AirPods', 'Apple AirPods Pro (2nd Generation)', 15000, 10, 'SKU-AIRPODS-002', TRUE),
('iPad', 'Apple iPad Air 5th Generation', 40000, 10, 'SKU-IPAD-005', TRUE);

-- Insert sample order
INSERT INTO orders (customer_id, total_amount, status, delivery_address)
VALUES (1, 70000, 'Processing', '123 Main Street, City, State 12345');

-- Insert sample order items
INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES (1, 2, 1, 70000);

-- Insert sample payment
INSERT INTO payments (order_id, payment_method, payment_status, amount, transaction_id)
VALUES (1, 'UPI', 'SUCCESS', 70000, 'TXN-2026-001-UPI');