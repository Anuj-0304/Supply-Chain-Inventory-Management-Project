-- Task 6: Find the best-performing customers
-- Business Question: 
-- Which 10 customers have spent the most money?
SELECT c.customer_id,
       c.customer_name,
       SUM(oi.quantity * oi.unit_price) AS total_spending
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC
LIMIT 10;


-- Task 7: Monthly Sales Revenue
-- Business Question: 
-- How much sales revenue was generated in each month?
SELECT DATE_TRUNC('month', o.order_date) AS month,
	   SUM(oi.quantity * oi.unit_price) AS total_sales_revenue
FROM orders o
JOIN order_items oi
	ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;


-- Task 8 : Business Question
-- Which products have generated more revenue than the average product revenue?
SELECT * 
FROM (
    SELECT 
        p.product_id, 
        p.product_name, 
        SUM(oi.quantity * oi.unit_price) AS total_revenue 
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
) AS product_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue) 
    FROM (
        SELECT 
            p.product_id,  
            SUM(oi.quantity * oi.unit_price) AS total_revenue 
        FROM products p
        JOIN order_items oi
            ON p.product_id = oi.product_id
        GROUP BY p.product_id
    ) AS revenues
);


-- Task 9: CASE WHEN.
-- Business Question: 
-- Classify each product based on its current stock level.

-- Rules:
-- quantity = 0 → Out of Stock
-- quantity <= reorder_level → Low Stock
-- quantity > reorder_level → Sufficient Stock

SELECT 
    p.product_id, 
    p.product_name,
    i.quantity,
    p.reorder_level,
    CASE
        WHEN i.quantity = 0 THEN 'Out of Stock'
        WHEN i.quantity <= p.reorder_level THEN 'Low Stock'
        WHEN i.quantity > p.reorder_level THEN 'Sufficient Stock'
        ELSE 'Unknown'
    END AS stock_status
FROM products p
JOIN inventory i
ON p.product_id = i.product_id;


-- Task 10: HAVING.
-- Business Question: 
-- Which product categories have generated more than ₹1,000,000 in total sales revenue?
SELECT 
    c.category_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM categories c
JOIN products p
    ON c.category_id = p.category_id
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY c.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 1000000;

