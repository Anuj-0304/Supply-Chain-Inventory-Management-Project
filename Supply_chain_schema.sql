CREATE TABLE categories (
    category_id VARCHAR(20) PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE suppliers (
    supplier_id VARCHAR(20) PRIMARY KEY,
    supplier_name VARCHAR(150) NOT NULL,
    city VARCHAR(80),
    state VARCHAR(80),
    phone VARCHAR(30),
    lead_time_days NUMERIC(5,1),
    quality_score NUMERIC(5,3) CHECK (quality_score BETWEEN 0 AND 1)
);

CREATE TABLE warehouses (
    warehouse_id VARCHAR(20) PRIMARY KEY,
    warehouse_name VARCHAR(150) NOT NULL,
    city VARCHAR(80),
    state VARCHAR(80),
    capacity_units INTEGER CHECK (capacity_units > 0)
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category_id VARCHAR(20) REFERENCES categories(category_id),
    supplier_id VARCHAR(20) REFERENCES suppliers(supplier_id),
    cost_price NUMERIC(12,2) CHECK (cost_price >= 0),
    selling_price NUMERIC(12,2) CHECK (selling_price >= 0),
    reorder_level INTEGER CHECK (reorder_level >= 0),
    status VARCHAR(30)
);

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    city VARCHAR(80),
    state VARCHAR(80),
    registration_date DATE,
    customer_segment VARCHAR(30)
);

CREATE TABLE inventory (
    inventory_id VARCHAR(20) PRIMARY KEY,
    warehouse_id VARCHAR(20) REFERENCES warehouses(warehouse_id),
    product_id VARCHAR(20) REFERENCES products(product_id),
    quantity INTEGER CHECK (quantity >= 0),
    reserved_quantity INTEGER CHECK (reserved_quantity >= 0),
    last_updated DATE,
    UNIQUE (warehouse_id, product_id)
);

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    order_status VARCHAR(30) NOT NULL
);

CREATE TABLE order_items (
    order_item_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20) REFERENCES orders(order_id),
    product_id VARCHAR(20) REFERENCES products(product_id),
    quantity INTEGER CHECK (quantity > 0),
    unit_price NUMERIC(12,2) CHECK (unit_price >= 0),
    discount_pct NUMERIC(5,2) CHECK (discount_pct BETWEEN 0 AND 1)
);

CREATE TABLE purchase_orders (
    purchase_order_id VARCHAR(20) PRIMARY KEY,
    supplier_id VARCHAR(20) REFERENCES suppliers(supplier_id),
    warehouse_id VARCHAR(20) REFERENCES warehouses(warehouse_id),
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    status VARCHAR(30)
);

CREATE TABLE purchase_order_items (
    purchase_order_item_id VARCHAR(20) PRIMARY KEY,
    purchase_order_id VARCHAR(20) REFERENCES purchase_orders(purchase_order_id),
    product_id VARCHAR(20) REFERENCES products(product_id),
    quantity INTEGER CHECK (quantity > 0),
    unit_cost NUMERIC(12,2) CHECK (unit_cost >= 0)
);

CREATE TABLE shipments (
    shipment_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20) REFERENCES orders(order_id),
    warehouse_id VARCHAR(20) REFERENCES warehouses(warehouse_id),
    shipment_date DATE,
    delivery_date DATE,
    carrier VARCHAR(80),
    status VARCHAR(30)
);

CREATE TABLE returns (
    return_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20) REFERENCES orders(order_id),
    product_id VARCHAR(20) REFERENCES products(product_id),
    return_date DATE,
    quantity INTEGER CHECK (quantity > 0),
    reason VARCHAR(100)
);


SELECT 'categories' AS table_name, COUNT(*) AS row_count FROM categories
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'warehouses', COUNT(*) FROM warehouses
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'purchase_orders', COUNT(*) FROM purchase_orders
UNION ALL
SELECT 'purchase_order_items', COUNT(*) FROM purchase_order_items
UNION ALL
SELECT 'shipments', COUNT(*) FROM shipments
UNION ALL
SELECT 'returns', COUNT(*) FROM returns
ORDER BY table_name;

-- Query to check the database is connected correctly or not
-- 1. Products → Categories → Suppliers
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    s.supplier_name
FROM products p
JOIN categories c
    ON p.category_id = c.category_id
JOIN suppliers s
    ON p.supplier_id = s.supplier_id
LIMIT 10;

-- 2. Inventory → Products → Warehouses
SELECT
    i.inventory_id,
    w.warehouse_name,
    p.product_name,
    i.quantity,
    i.reserved_quantity
FROM inventory i
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
JOIN products p
    ON i.product_id = p.product_id
LIMIT 10;

-- 3. Customers → Orders → Order Items → Products
SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
LIMIT 10;

-- 4. Suppliers → Purchase Orders → Purchase Order Items
SELECT
    s.supplier_name,
    po.purchase_order_id,
    po.order_date,
    p.product_name,
    poi.quantity,
    poi.unit_cost
FROM suppliers s
JOIN purchase_orders po
    ON s.supplier_id = po.supplier_id
JOIN purchase_order_items poi
    ON po.purchase_order_id = poi.purchase_order_id
JOIN products p
    ON poi.product_id = p.product_id
LIMIT 10;

