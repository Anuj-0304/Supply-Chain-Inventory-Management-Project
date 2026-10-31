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
