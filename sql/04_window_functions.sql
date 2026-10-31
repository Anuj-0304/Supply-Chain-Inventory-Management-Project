-- Task 16: Running Total (Cumulative Sum)
-- Calculate the cumulative sales revenue generated over time, based on order dates.
WITH daily_sales AS (	
	SELECT DATE(o.order_date) AS order_date,
		   SUM(oi.quantity * oi.unit_price) AS daily_revenue
	FROM orders o
	JOIN order_items oi
		ON o.order_id = oi.order_id
	GROUP BY o.order_date
)
SELECT order_date,
	   daily_revenue,
	   SUM(daily_revenue) OVER (
	   	   ORDER BY order_date
	   ) AS running_total
FROM daily_sales
ORDER BY order_date;


-- Task 17: Previous day's revenue using LAG()
-- Compare each day's sales revenue with the previous recorded day's sales revenue.
WITH daily_sales AS (	
	SELECT DATE(o.order_date) AS order_date,
		   SUM(oi.quantity * oi.unit_price) AS daily_revenue
	FROM orders o
	JOIN order_items oi
		ON o.order_id = oi.order_id
	GROUP BY DATE(o.order_date)
),
previous_sales AS (
	SELECT order_date,
		   daily_revenue,
		   LAG(daily_revenue) OVER (
		   	   ORDER BY order_date
		   ) AS previous_day_revenue
	FROM daily_sales
)
SELECT order_date,
	   daily_revenue,
	   previous_day_revenue,
	   (daily_revenue - previous_day_revenue) AS revenue_difference
FROM previous_sales
ORDER BY order_date;


-- Task 18: Revenue percentage change
-- Calculate the percentage increase or decrease in daily revenue compared with the previous recorded day.
-- Formula: Percentage Change = ({(Current Revenue)-(Previous Revenue)}/(Previous Revenue)) * 100
WITH current_revenue AS (	
	SELECT DATE(o.order_date) AS order_date,
		   SUM(oi.quantity * oi.unit_price) AS current_revenue
	FROM orders o
	JOIN order_items oi
		ON o.order_id = oi.order_id
	GROUP BY DATE(o.order_date)
),
previous_sales AS (
	SELECT order_date,
		   current_revenue,
		   LAG(current_revenue) OVER (
		   	   ORDER BY order_date
		   ) AS previous_day_revenue
	FROM current_revenue
)
SELECT order_date,
	   current_revenue,
	   previous_day_revenue,
	   (
	   	   (current_revenue - previous_day_revenue) / NULLIF(previous_day_revenue, 0) 
		)* 100 AS revenue_percentage_change
FROM previous_sales
ORDER BY order_date;


-- Task 19: Moving Average
-- Calculate the 7-day moving average of daily sales revenue.
WITH current_revenue AS (	
	SELECT DATE(o.order_date) AS order_date,
		   SUM(oi.quantity * oi.unit_price) AS current_revenue
	FROM orders o
	JOIN order_items oi
		ON o.order_id = oi.order_id
	GROUP BY DATE(o.order_date)
),
previous_sales AS (
	SELECT order_date,
		   current_revenue,
		   AVG(current_revenue) OVER (
		   	   ORDER BY order_date
			   ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
		   ) AS moving_average_7_days
	FROM current_revenue
)
SELECT order_date,
	   current_revenue,
	   moving_average_7_days
FROM previous_sales
ORDER BY order_date;


-- Task 20: Identify sales trends
-- Find the days when daily revenue was higher than the previous day's revenue.
WITH current_revenue AS (	
	SELECT DATE(o.order_date) AS order_date,
		   SUM(oi.quantity * oi.unit_price) AS current_revenue
	FROM orders o
	JOIN order_items oi
		ON o.order_id = oi.order_id
	GROUP BY DATE(o.order_date)
),
previous_sales AS (
	SELECT order_date,
		   current_revenue,
		   LAG(current_revenue) OVER (
		   	   ORDER BY order_date
		   ) AS previous_day_revenue
	FROM current_revenue
)
SELECT order_date,
	   current_revenue,
	   previous_day_revenue
FROM previous_sales
WHERE current_revenue > previous_day_revenue
ORDER BY order_date;
