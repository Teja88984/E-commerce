SELECT * FROM customers;

SELECT product_name, stock FROM products;

SELECT orders.order_id, customers.name, orders.total_amount
FROM orders
JOIN customers ON orders.customer_id = customers.customer_id;

SELECT product_name, AVG(rating) FROM reviews
JOIN products ON reviews.product_id = products.product_id
GROUP BY product_name;
