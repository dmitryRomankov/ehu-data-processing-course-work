CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    description VARCHAR(500)
);

CREATE TABLE brands (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(255) NOT NULL,
    country_of_origin VARCHAR(100)
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category_id INT NOT NULL,
    brand_id INT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    stock_quantity INT NOT NULL,
    description VARCHAR(1000),
    CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES Categories (category_id),
    CONSTRAINT fk_brand FOREIGN KEY (brand_id) REFERENCES Brands (brand_id)
);

CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255),
    phone_number VARCHAR(20),
    email VARCHAR(255),
    address VARCHAR(500)
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20),
    address VARCHAR(500)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES Customers (customer_id)
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price_per_unit NUMERIC(10, 2) NOT NULL,
    CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES Orders (order_id),
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES Products (product_id)
);

CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    supplier_id INT NOT NULL,
    restock_date DATE NOT NULL,
    restock_quantity INT NOT NULL,
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES Products (product_id),
    CONSTRAINT fk_supplier FOREIGN KEY (supplier_id) REFERENCES Suppliers (supplier_id)
);
