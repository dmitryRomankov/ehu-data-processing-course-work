-- SQL script to insert data into the kitchen gadgets database (PostgreSQL syntax)

INSERT INTO categories (category_name, description) VALUES
('Cooking Tools', 'Utensils and tools used for cooking tasks'),
('Cutlery', 'Knives and cutting equipment'),
('Storage', 'Containers for food storage');

INSERT INTO brands (brand_name, country_of_origin) VALUES
('KitchenPro', 'USA'),
('BladeMaster', 'Germany'),
('FoodSaver', 'France');

INSERT INTO products (product_name, category_id, brand_id, price, stock_quantity, description) VALUES
('Stainless Steel Spatula', 1, 1, 12.99, 200, 'Durable spatula for flipping and mixing'),
('Chef\'s Knife', 2, 2, 45.50, 50, 'Professional-grade chef\'s knife'),
('Glass Storage Container', 3, 3, 8.75, 300, 'Glass container with airtight seal');

INSERT INTO suppliers (supplier_name, contact_name, phone_number, email, address) VALUES
('Global Supply Co.', 'John Doe', '123-456-7890', 'john.doe@supplyco.com', '123 Supply St, Cityville'),
('Culinary Imports', 'Jane Smith', '987-654-3210', 'jane.smith@culinary.com', '456 Import Ave, Townsville'),
('Kitchen Essentials', 'Alice Brown', '555-555-5555', 'alice.brown@essentials.com', '789 Kitchen Rd, Metropolis');

INSERT INTO customers (first_name, last_name, email, phone_number, address) VALUES
('Michael', 'Johnson', 'michael.johnson@example.com', '111-222-3333', '100 Main St, Example City'),
('Emily', 'Davis', 'emily.davis@example.com', '222-333-4444', '200 Oak St, Sample Town'),
('David', 'Smith', 'david.smith@example.com', '333-444-5555', '300 Pine St, Demo Village');

INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2025-01-06', 58.99),
(2, '2025-01-07', 45.50),
(3, '2025-01-08', 12.99);

INSERT INTO order_items (order_id, product_id, quantity, price_per_unit) VALUES
(1, 1, 2, 12.99),
(2, 2, 1, 45.50),
(3, 1, 1, 12.99);

INSERT INTO inventory (product_id, supplier_id, restock_date, restock_quantity) VALUES
(1, 1, '2025-01-02', 150),
(2, 2, '2025-01-03', 75),
(3, 3, '2025-01-04', 200);
