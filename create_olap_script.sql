-- Create a new database for OLAP to separate it from OLTP

CREATE TABLE dim_customers (
    customer_key SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone_number VARCHAR(20),
    address VARCHAR(500),
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN NOT NULL,
    CONSTRAINT unique_customer_scd UNIQUE (customer_id, start_date)
);

CREATE TABLE dim_categories (
    category_key SERIAL PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    description VARCHAR(500)
);

CREATE TABLE dim_brands (
    brand_key SERIAL PRIMARY KEY,
    brand_name VARCHAR(255) NOT NULL,
    country_of_origin VARCHAR(100)
);

CREATE TABLE dim_products (
    product_key SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    category_id INT,
    brand_id INT,
    CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES dim_categories (category_key),
    CONSTRAINT fk_brand FOREIGN KEY (brand_id) REFERENCES dim_brands (brand_key)
);

CREATE TABLE dim_date (
    date_key SERIAL PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT,
    month INT,
    day INT,
    week INT,
    quarter INT
);

CREATE TABLE fact_sales (
    sales_key SERIAL PRIMARY KEY,
    product_key INT NOT NULL,
    customer_key INT,
    date_key INT NOT NULL,
    quantity_sold INT NOT NULL,
    total_sales_amount NUMERIC(12, 2) NOT NULL,
    CONSTRAINT fk_product FOREIGN KEY (product_key) REFERENCES dim_products (product_key),
    CONSTRAINT fk_customer FOREIGN KEY (customer_key) REFERENCES dim_customers (customer_key),
    CONSTRAINT fk_date FOREIGN KEY (date_key) REFERENCES dim_date (date_key)
);

CREATE TABLE fact_inventory (
    inventory_key SERIAL PRIMARY KEY,
    product_key INT NOT NULL,
    supplier_id INT,
    date_key INT NOT NULL,
    stock_added INT,
    stock_remaining INT,
    CONSTRAINT fk_product_inventory FOREIGN KEY (product_key) REFERENCES dim_products (product_key),
    CONSTRAINT fk_date_inventory FOREIGN KEY (date_key) REFERENCES dim_date (date_key)
);

CREATE MATERIALIZED VIEW mv_monthly_sales AS
SELECT
    d.year,
    d.month,
    p.product_name,
    c.category_name,
    SUM(f.quantity_sold) AS total_quantity,
    SUM(f.total_sales_amount) AS total_sales
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_products p ON f.product_key = p.product_key
JOIN dim_categories c ON p.category_id = c.category_key
GROUP BY d.year, d.month, p.product_name, c.category_name;

INSERT INTO dim_date (full_date, year, month, day, week, quarter)
SELECT generate_series('2021-01-01'::DATE, '2025-12-31'::DATE, '1 day')::DATE AS full_date,
       EXTRACT(YEAR FROM full_date),
       EXTRACT(MONTH FROM full_date),
       EXTRACT(DAY FROM full_date),
       EXTRACT(WEEK FROM full_date),
       EXTRACT(QUARTER FROM full_date);


INSERT INTO dim_customers (customer_id, first_name, last_name, email, phone_number, address, start_date, is_current)
SELECT DISTINCT customer_id, first_name, last_name, email, phone_number, address, CURRENT_DATE, TRUE
FROM oltp_db.Customers c
ON CONFLICT (customer_id, start_date) DO NOTHING;
