CREATE OR REPLACE VIEW BetterRestockLog AS
SELECT 
    rl.log_id,
    rl.product_id,
    p.name,
    rl.location,
    rl.quantity_added,
    rl.updated_at,
    rr.reason_description AS reason_name
FROM 
    RestockLog rl
JOIN 
    Products p
ON 
    rl.product_id = p.product_id
JOIN 
    RestockReasons rr
ON 
    rl.reason_id = rr.reason_id;
