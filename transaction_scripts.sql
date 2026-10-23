-- =========================================================================
-- TASK 05: Query Index Tuning, Execution Plans & ACID Transactions
-- =========================================================================

-- 1. DROP & CREATE TABLE
DROP TABLE IF EXISTS inventory_items;

CREATE TABLE inventory_items (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(50) NOT NULL,
    warehouse_location VARCHAR(100) NOT NULL,
    stock_quantity INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. SEED 60,000+ ROWS TO FORCE SEQUENTIAL SCANS
INSERT INTO inventory_items (sku, warehouse_location, stock_quantity, category)
SELECT 
    'SKU-' || generate_series(1, 60000),
    CASE (random() * 3)::INT 
        WHEN 0 THEN 'North Warehouse' 
        WHEN 1 THEN 'South Warehouse' 
        ELSE 'East Warehouse' END,
    (random() * 500)::INT,
    CASE (random() * 2)::INT 
        WHEN 0 THEN 'Electronics' 
        WHEN 1 THEN 'Apparel' 
        ELSE 'Home Goods' END;

ANALYZE inventory_items;


-- =========================================================================
-- 3. BEFORE INDEXING: EXPLAIN ANALYZE
-- =========================================================================
EXPLAIN ANALYZE 
SELECT * FROM inventory_items 
WHERE warehouse_location = 'North Warehouse' AND category = 'Electronics';


-- =========================================================================
-- 4. CREATE STRATEGIC INDEXES
-- =========================================================================
CREATE INDEX idx_inventory_warehouse ON inventory_items(warehouse_location);
CREATE INDEX idx_warehouse_category ON inventory_items(warehouse_location, category);
CREATE INDEX idx_low_stock ON inventory_items(stock_quantity) WHERE stock_quantity < 10;


-- =========================================================================
-- 5. AFTER INDEXING: EXPLAIN ANALYZE
-- =========================================================================
EXPLAIN ANALYZE 
SELECT * FROM inventory_items 
WHERE warehouse_location = 'North Warehouse' AND category = 'Electronics';


-- =========================================================================
-- 6. SAFE ACID TRANSACTION BLOCK WITH CONCURRENCY CONTROL
-- =========================================================================
BEGIN;

SELECT id, stock_quantity 
FROM inventory_items 
WHERE id = 42 
FOR UPDATE;

UPDATE inventory_items 
SET stock_quantity = stock_quantity - 5 
WHERE id = 42 AND stock_quantity >= 5;

COMMIT;