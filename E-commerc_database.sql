-- Database: E-commerce

CREATE DATABASE E-commerce;
USE E-commerce;

-- Table Definitions
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(50) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Sample Data Insertion
INSERT INTO Users (Username, PasswordHash, Email) VALUES ('john_doe', 'hashed_password', 'john@example.com');
INSERT INTO Products (ProductName, Price, Stock) VALUES ('Laptop', 999.99, 50);

-- Triggers
CREATE TRIGGER after_product_insert
AFTER INSERT ON Products
FOR EACH ROW
BEGIN
    INSERT INTO InventoryLog (ProductID, ChangeType, ChangeAmount, ChangeDate)
    VALUES (NEW.ProductID, 'INSERT', 1, NOW());
END;
