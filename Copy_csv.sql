-- SQL script to load CSV data into PostgreSQL tables `categories` and `products`

-- Categories from csv

CREATE TEMP TABLE temp_categories (
    category_id INT,
    category_name VARCHAR(255),
    description VARCHAR(500)
);

COPY temp_categories (category_id, category_name, description)
FROM 'C:\data\categories.csv' DELIMITER ',' CSV HEADER;

select * from temp_categories;

INSERT INTO categories (category_id, category_name, description)
SELECT t.category_id, t.category_name, t.description
FROM temp_categories t
ON CONFLICT (category_id) DO UPDATE
SET category_name = EXCLUDED.category_name,
    description = EXCLUDED.description
WHERE Categories.category_name IS DISTINCT FROM EXCLUDED.category_name
   OR Categories.description IS DISTINCT FROM EXCLUDED.description;


DROP TABLE IF EXISTS temp_categories;

-- Products from csv

CREATE TEMP TABLE temp_products (
    product_id INT,
    product_name VARCHAR(255),
    category_id INT,
    brand_id INT,
    price NUMERIC(10, 2),
    stock_quantity INT,
    description VARCHAR(1000)
);

COPY temp_products (product_id, product_name, category_id, brand_id, price, stock_quantity, description)
FROM 'C:\data\products.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Products (product_id, product_name, category_id, brand_id, price, stock_quantity, description)
SELECT t.product_id, t.product_name, t.category_id, t.brand_id, t.price, t.stock_quantity, t.description
FROM temp_products t
ON CONFLICT (product_id) DO UPDATE
SET product_name = EXCLUDED.product_name,
    category_id = EXCLUDED.category_id,
    brand_id = EXCLUDED.brand_id,
    price = EXCLUDED.price,
    stock_quantity = EXCLUDED.stock_quantity,
    description = EXCLUDED.description
WHERE Products.product_name IS DISTINCT FROM EXCLUDED.product_name
   OR Products.category_id IS DISTINCT FROM EXCLUDED.category_id
   OR Products.brand_id IS DISTINCT FROM EXCLUDED.brand_id
   OR Products.price IS DISTINCT FROM EXCLUDED.price
   OR Products.stock_quantity IS DISTINCT FROM EXCLUDED.stock_quantity
   OR Products.description IS DISTINCT FROM EXCLUDED.description;


DROP TABLE IF EXISTS temp_products;

