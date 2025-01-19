-- This query calculates the total sales for each customer based on the Orders table.
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_sales DESC;

--This query identifies products with stock below a critical threshold.
SELECT 
    p.product_id,
    p.product_name,
    p.stock_quantity
FROM products p
WHERE p.stock_quantity < 10
ORDER BY p.stock_quantity ASC;

--This query calculates which suppliers have restocked the most products.
SELECT 
    s.supplier_name,
    COUNT(i.inventory_id) AS restock_count
FROM suppliers s
JOIN inventory i ON s.supplier_id = i.supplier_id
GROUP BY s.supplier_name
ORDER BY restock_count DESC;
