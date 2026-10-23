# Database Optimization & Index Tuning Report

## 1. Overview & Dataset
- **Table Name:** `inventory_items`
- **Row Count:** 60,000 simulated rows.
- **Objective:** Identify slow sequential scans using `EXPLAIN ANALYZE`, apply strategic B-Tree, Composite, and Partial indexes, measure execution time improvements, and execute safe ACID transaction blocks.

## 2. Baseline Performance (Before Indexing)
- **Query Executed:**
  ```sql
  EXPLAIN ANALYZE 
  SELECT * FROM inventory_items 
  WHERE warehouse_location = 'North Warehouse' AND category = 'Electronics';