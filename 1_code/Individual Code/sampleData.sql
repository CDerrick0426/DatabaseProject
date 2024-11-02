INSERT INTO Categories (name, description)
VALUES
    ('Dairy', 'Milk, cheese, yogurt, and other dairy products'),
    ('Meat', 'All types of meats and poultry'),
    ('Shelf Foods', 'Non-perishable items like canned goods, pasta, etc.'),
    ('Produce', 'Fresh fruits and vegetables'),
    ('Frozen Foods', 'Frozen meals and products');

INSERT INTO Products (name, category_id, sku, price)
VALUES
    ('Whole Milk', 1, 'DAIRY-001', 3.50), -- Creates the items with the name, category id, sku and price.
    ('Chicken Breast', 2, 'MEAT-001', 5.00),
    ('Canned Beans', 3, 'SHELF-001', 1.25),
    ('Apples', 4, 'PROD-001', 0.75),
    ('Frozen Pizza', 5, 'FROZEN-001', 4.00);

INSERT INTO Stock (product_id, location, quantity)
VALUES
    (1, 'sales_floor', 20), -- Inserts 20 whole milk gallons onto the sales floor, since they have ID 1
    (1, 'reserve', 50), -- Inserts 50 whole milk gallons into reserve since they have ID 1, etcetera
    (2, 'sales_floor', 15),
    (2, 'reserve', 30),
    (3, 'sales_floor', 40),
    (3, 'reserve', 80),
    (4, 'sales_floor', 25),
    (4, 'reserve', 60),
    (5, 'sales_floor', 10),
    (5, 'reserve', 20);