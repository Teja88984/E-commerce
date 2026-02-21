-- Trigger to validate and update customer loyalty points on order completion
CREATE TRIGGER update_loyalty_points
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE loyalty_points INT;
    SET loyalty_points = NEW.total_amount * 0.1; -- 10% of the total amount
    UPDATE customers SET loyalty_points = loyalty_points + loyalty_points
    WHERE id = NEW.customer_id;
END;

-- Trigger to send notification alerts when product stock falls below threshold
CREATE TRIGGER stock_threshold_alert
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF NEW.stock < NEW.threshold THEN
        CALL send_notification(NEW.product_id);
    END IF;
END;

-- Trigger to automatically calculate and update product discounts
CREATE TRIGGER auto_discount_update
BEFORE INSERT OR UPDATE ON products
FOR EACH ROW
BEGIN
    IF (NEW.price > 100) THEN
        SET NEW.discount = 0.1; -- 10% discount for products over $100
    ELSE
        SET NEW.discount = 0.05; -- 5% discount for lower priced products
    END IF;
END;

-- Trigger to maintain customer purchase frequency statistics
CREATE TRIGGER update_purchase_frequency
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    UPDATE customers SET purchase_frequency = purchase_frequency + 1
    WHERE id = NEW.customer_id;
END;

-- Trigger to archive old orders automatically
CREATE TRIGGER archive_old_orders
BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO archived_orders SELECT * FROM orders WHERE id = OLD.id;
END;

-- Trigger to validate payment amounts match order totals
CREATE TRIGGER validate_payment_amount
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
    DECLARE order_total DECIMAL(10, 2);
    SELECT total_amount INTO order_total FROM orders WHERE id = NEW.order_id;
    IF NEW.amount <> order_total THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment amount does not match order total';
    END IF;
END;

-- Trigger to prevent duplicate reviews from same customer for same product
CREATE TRIGGER prevent_duplicate_reviews
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM reviews WHERE customer_id = NEW.customer_id AND product_id = NEW.product_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate review from same customer for the same product';
    END IF;
END;

-- Trigger to update product rating averages automatically
CREATE TRIGGER update_product_ratings
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    UPDATE products SET average_rating = (SELECT AVG(rating) FROM reviews WHERE product_id = NEW.product_id)
    WHERE id = NEW.product_id;
END;

-- Trigger to log all customer address changes for audit purposes
CREATE TRIGGER log_address_changes
AFTER UPDATE ON customers
FOR EACH ROW
BEGIN
    IF OLD.address <> NEW.address THEN
        INSERT INTO address_changes(customer_id, old_address, new_address, change_date)
        VALUES (NEW.id, OLD.address, NEW.address, NOW());
    END IF;
END;

-- Trigger to enforce business rules for order cancellations
CREATE TRIGGER enforce_order_cancellation_rules
BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status = 'shipped' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Cannot cancel an order that has already been shipped';
    END IF;
END;
