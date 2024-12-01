CREATE VIEW BetterRestockLog AS
SELECT 
    rl.log_id,
    rl.product_id,
    p.name,
    rl.location,
    rl.quantity_added,
    rl.updated_at
FROM 
    RestockLog rl
JOIN 
    Products p
ON 
    rl.product_id = p.product_id;