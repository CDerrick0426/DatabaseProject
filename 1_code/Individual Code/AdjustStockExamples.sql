-- To use the procedure, type in the product ID, location, and how much to add.
-- Examples given below.

CALL AdjustStock(productID, 'sales_floor', stockAmount, reasonID); 
CALL AdjustStock(productID, 'reserve', stockAmount, reasonID);

-- Reason ID List
-- 10: Normal Restock
-- 11: Expired Products
-- 12: Broken Items
-- 13: Missing Items
-- 14: Excessive Demand
