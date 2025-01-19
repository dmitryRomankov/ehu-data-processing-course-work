--This query aggregates monthly sales by product category.
SELECT 
    d.year,
    d.month,
    c.category_name,
    SUM(fs.quantity_sold) AS total_quantity,
    SUM(fs.total_sales_amount) AS total_sales
FROM fact_sales fs
JOIN dim_date d ON fs.date_key = d.date_key
JOIN dim_products p ON fs.product_key = p.product_key
JOIN dim_categories c ON p.category_id = c.category_key
GROUP BY d.year, d.month, c.category_name
ORDER BY d.year, d.month, c.category_name;

--This query identifies the top customers based on total sales.
SELECT 
    CONCAT(dc.first_name, ' ', dc.last_name) AS customer_name,
    SUM(fs.total_sales_amount) AS total_sales
FROM fact_sales fs
JOIN dim_customers dc ON fs.customer_key = dc.customer_key
GROUP BY dc.first_name, dc.last_name
ORDER BY total_sales DESC
LIMIT 10;

--This query calculates the year-over-year sales growth.
WITH yearly_sales AS (
    SELECT 
        d.year,
        SUM(fs.total_sales_amount) AS total_sales
    FROM fact_sales fs
    JOIN dim_date d ON fs.date_key = d.date_key
    GROUP BY d.year
)
SELECT 
    y1.year AS current_year,
    y1.total_sales AS current_sales,
    y2.total_sales AS previous_sales,
    ROUND((y1.total_sales - y2.total_sales) * 100.0 / y2.total_sales, 2) AS sales_growth_percentage
FROM yearly_sales y1
LEFT JOIN yearly_sales y2 ON y1.year = y2.year + 1
ORDER BY y1.year;
