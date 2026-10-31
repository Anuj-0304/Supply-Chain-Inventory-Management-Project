-- Task 11: CTE
-- Business Question: 
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


-- Task 12: Window Functions
-- Business Question: 
-- Question: Rank all products based on their total sales revenue, from highest to lowest.
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
	   ps.total_sales_revenue,
	   RANK() OVER (
	  		ORDER BY ps.total_sales_revenue DESC
	   ) AS sales_rank
FROM product_sales ps
ORDER BY sales_rank;


-- Task 13: Rank products within each category
-- Business Question: 
-- Rank products by total sales revenue separately within each product category.
-- For example, each category should have its own rank 1, rank 2, and rank 3.
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
	   ps.category_id,
	   c.category_name,
	   ps.total_sales_revenue,
	   RANK() OVER (
	   	 	PARTITION BY ps.category_id
			ORDER BY ps.total_sales_revenue DESC
	   ) AS category_rank
FROM product_sales ps
JOIN categories c
	ON ps.category_id = c.category_id
ORDER BY c.category_name, category_rank;


-- Task 14: ROW_NUMBER()
-- Business question: 
-- Find the single highest-revenue product in each category.
WITH product_sales AS (
	SELECT p.product_id,
		   p.product_name,
		   p.category_id,
		   SUM(oi.quantity * oi.unit_price) AS total_sales_revenue
	FROM products p
	JOIN order_items oi
		ON p. product_id = oi.product_id
	GROUP BY p.product_id, p.product_name, p.category_id 
),
ranked_products AS (
	SELECT ps.product_id,
		   ps.product_name,
		   ps.category_id,
		   c.category_name,
		   ps.total_sales_revenue,
		   ROW_NUMBER() OVER (
		   	 	PARTITION BY ps.category_id
				ORDER BY
					ps.total_sales_revenue DESC,
					ps.product_id ASC
		) AS row_num
	FROM product_sales ps
	JOIN categories c
		ON ps.category_id = c.category_id
)		
SELECT product_id,
	   product_name,
	   category_id,
	   category_name,
	   total_sales_revenue
FROM ranked_products
WHERE row_num = 1
ORDER BY category_name;


-- Task 15: DENSE_RANK()
-- Business Question: 
-- Rank all products by total sales revenue, ensuring that tied products receive the same rank without skipping any rank numbers.
WITH product_sales AS (
	SELECT p.product_id,
		   p.product_name,
		   p.category_id,
		   SUM(oi.quantity * oi.unit_price) AS total_sales_revenue
	FROM products p
	JOIN order_items oi
		ON p. product_id = oi.product_id
	GROUP BY p.product_id, p.product_name, p.category_id 
),
ranked_products AS (
	SELECT ps.product_id,
		   ps.product_name,
		   ps.category_id,
		   c.category_name,
		   ps.total_sales_revenue,
		   DENSE_RANK() OVER (
				ORDER BY
					ps.total_sales_revenue DESC
		) AS sales_rank
	FROM product_sales ps
	JOIN categories c
		ON ps.category_id = c.category_id
)		
SELECT product_id,
	   product_name,
	   category_id,
	   category_name,
	   total_sales_revenue,
	   sales_rank
FROM ranked_products
ORDER BY total_sales_revenue DESC;

