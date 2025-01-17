CREATE EXTENSION IF NOT EXISTS postgres_fdw;

SELECT * FROM pg_authid WHERE rolname='postgres';

-- Connection to OLTP db
DROP SERVER IF EXISTS oltp_server CASCADE;
CREATE SERVER oltp_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', dbname 'kitchen-gadgets-course-work', port '5433');

CREATE USER MAPPING FOR CURRENT_USER
SERVER oltp_server
OPTIONS (user 'postgres', password 'postgres');

IMPORT FOREIGN SCHEMA public
  LIMIT TO (brands, categories, customers, inventory, order_items, orders, suppliers, products)
  FROM SERVER oltp_server
  INTO public;

CREATE TEMP TABLE valid_categories AS
SELECT category_id, category_name FROM categories;

CREATE TEMP TABLE valid_brands AS
SELECT brand_id, brand_name FROM brands;

-- Define valid date range (e.g., data from the last 12 months)
CREATE TEMP TABLE valid_dates AS
SELECT generate_series(CURRENT_DATE - INTERVAL '1 year', CURRENT_DATE, '1 day')::DATE AS valid_date;

-- Extract Orders and related data
WITH extracted_orders AS (
    SELECT 
        o.order_id, 
        o.order_date, 
        o.customer_id, 
        o.total_amount,
        oi.product_id, 
        oi.quantity, 
        oi.price_per_unit
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_date >= (CURRENT_DATE - INTERVAL '1 year')
)
SELECT * FROM extracted_orders;

CREATE TEMP TABLE stage_fact_sales (
    sales_date DATE,
    product_id INT,
    total_quantity INT,
    total_sales NUMERIC(12, 2)
);

WITH extracted_orders AS (
    SELECT 
        o.order_id, 
        o.order_date, 
        o.customer_id, 
        o.total_amount,
        oi.product_id, 
        oi.quantity, 
        oi.price_per_unit
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_date >= (CURRENT_DATE - INTERVAL '1 year')
),
validated_orders AS (
    SELECT eo.*
    FROM extracted_orders eo
    WHERE eo.order_date >= (CURRENT_DATE - INTERVAL '1 year')
),
daily_sales AS (
    SELECT 
        DATE(order_date) AS sales_date,
        product_id,
        SUM(quantity) AS total_quantity,
        SUM(quantity * price_per_unit) AS total_sales
    FROM validated_orders
    GROUP BY DATE(order_date), product_id
)
INSERT INTO stage_fact_sales SELECT * FROM daily_sales; 

CREATE TEMP TABLE stage_dim_customers AS
SELECT DISTINCT c.customer_id, c.first_name, c.last_name, c.email, c.phone_number, c.address
FROM customers c
WHERE c.customer_id IN (
    SELECT DISTINCT o.customer_id
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_date >= (CURRENT_DATE - INTERVAL '1 year')
);

-- Insert into dim_date
INSERT INTO dim_date (full_date, year, month, day, week, quarter)
SELECT DISTINCT sales_date, 
    EXTRACT(YEAR FROM sales_date), 
    EXTRACT(MONTH FROM sales_date), 
    EXTRACT(DAY FROM sales_date), 
    EXTRACT(WEEK FROM sales_date), 
    EXTRACT(QUARTER FROM sales_date)
FROM stage_fact_sales
ON CONFLICT DO NOTHING;

-- Alter the table to add a unique constraint
ALTER TABLE dim_customers ADD CONSTRAINT unique_customer_id UNIQUE (customer_id);
ALTER TABLE dim_customers ALTER COLUMN start_date SET DEFAULT CURRENT_DATE;

-- Insert into dim_customers
INSERT INTO dim_customers (customer_id, first_name, last_name, email, phone_number, address, start_date, is_current)
SELECT 
    customer_id,
    first_name,
    last_name,
    email,
    phone_number,
    address,
    CURRENT_DATE AS start_date,
    TRUE AS is_current
FROM stage_dim_customers
ON CONFLICT (customer_id)
DO UPDATE SET 
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    email = EXCLUDED.email,
    phone_number = EXCLUDED.phone_number,
    address = EXCLUDED.address;

ALTER TABLE dim_customers
ALTER COLUMN start_date DROP NOT NULL;

-- Insert into fact_sales
INSERT INTO fact_sales (date_key, product_key, quantity_sold, total_sales_amount)
SELECT d.date_key, p.product_id, s.total_quantity, s.total_sales
FROM stage_fact_sales s
JOIN dim_date d ON s.sales_date = d.full_date
JOIN dim_products p ON s.product_id = p.product_id
ON CONFLICT DO NOTHING;

DROP TABLE IF EXISTS valid_categories;
DROP TABLE IF EXISTS valid_brands;
DROP TABLE IF EXISTS valid_dates;
DROP TABLE IF EXISTS stage_fact_sales;
DROP TABLE IF EXISTS stage_dim_customers;

