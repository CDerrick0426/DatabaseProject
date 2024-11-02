CREATE VIEW ProductStockOverview AS
SELECT 
    p.product_id,
    p.name AS product_name,
    COALESCE(SUM(CASE WHEN s.location = 'sales_floor' THEN s.quantity END), 0) AS sales_floor_quantity,
    MAX(CASE WHEN s.location = 'sales_floor' THEN s.last_updated END) AS sales_floor_last_updated,
    COALESCE(SUM(CASE WHEN s.location = 'reserve' THEN s.quantity END), 0) AS reserve_quantity,
    MAX(CASE WHEN s.location = 'reserve' THEN s.last_updated END) AS reserve_last_updated
FROM Products p
LEFT JOIN Stock s ON p.product_id = s.product_id
GROUP BY p.product_id, p.name;