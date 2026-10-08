-- Phase 1: Data Analyst SQL

-- Task 1: Understand the product catalog
-- 1.How many products are available in each product category?
SELECT c.category_name, 
	   COUNT(p.category_id) AS product_count
FROM products p
JOIN categories c 
	ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY product_count DESC;

-- Task 2: Inventory Analysis
-- 2.Which products currently have inventory below or equal to their reorder level?
SELECT p.product_id,
       p.product_name,
       i.quantity,
       p.reorder_level
FROM products p
JOIN inventory i 
    ON p.product_id = i.product_id
WHERE i.quantity <= p.reorder_level
ORDER BY i.quantity ASC;

-- 3.Which 10 products have generated the highest total sales revenue?
SELECT p.product_id,
       p.product_name,
       SUM(oi.quantity * oi.unit_price) AS total_sales_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales_revenue DESC
LIMIT 10;


-- Task 4 : Business Question: 
-- Which product categories generate the highest total sales revenue? 
SELECT c.category_name, 
	   SUM(oi.quantity * oi.unit_price) AS total_sales_revenue 
FROM categories c 
JOIN products p 
	ON c.category_id = p.category_id 
JOIN order_items oi 
	ON p.product_id = oi.product_id 
GROUP BY c.category_name 
ORDER BY total_sales_revenue DESC;


-- Task 5: Supplier performance
-- Which suppliers have the highest total purchase order value?
SELECT s.supplier_name,
       SUM(poi.quantity * poi.unit_cost) AS total_purchase_cost
FROM suppliers s
JOIN purchase_orders p 
    ON s.supplier_id = p.supplier_id
JOIN purchase_order_items poi 
    ON p.purchase_order_id = poi.purchase_order_id
GROUP BY s.supplier_name
ORDER BY total_purchase_cost DESC;

-- Task 6: Find the best-performing customers
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


-- Task 11: CTE
-- Find the top 10 products by total sales revenue, but display their category name as well.
WITH product_sales AS (
	SELECT p.product_id,
		   p.product_name,
		   p.category_id,
		   SUM(oi.quantity * oi.unit_price) AS total_sales_revenue
	FROM products p
	JOIN order_items oi
		ON p. product_id = oi.product_id
	GROUP BY p.product_id, p.product_name, p.category_id 
)
SELECT ps.product_id,
	   ps.product_name,
	   c.category_name,
	   ps.total_sales_revenue
FROM product_sales ps
JOIN categories c
	ON ps.category_id = c.category_id
ORDER BY ps.total_sales_revenue DESC
LIMIT 10;

