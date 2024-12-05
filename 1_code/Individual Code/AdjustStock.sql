DELIMITER //

CREATE PROCEDURE AdjustStock(
    IN productId INT,
    IN location ENUM('sales_floor', 'reserve'),
    IN quantityChange INT,
    IN reasonId INT
)
BEGIN
    DECLARE current_reserve_quantity INT;

    -- If restocking sales floor
    IF location = 'sales_floor' AND quantityChange > 0 THEN
        -- Get current reserve stock
        SELECT quantity INTO current_reserve_quantity
        FROM Stock
        WHERE product_id = productId AND location = 'reserve';

        -- If there isn't enough stock, throw an error
        IF current_reserve_quantity < quantityChange THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Not enough stock in reserve to fulfill this transfer to sales floor.';
        END IF;

        UPDATE Stock
        SET quantity = quantity + quantityChange
        WHERE product_id = productId AND location = 'sales_floor';

        -- Subtract from reserve stock
        UPDATE Stock
        SET quantity = quantity - quantityChange
        WHERE product_id = productId AND location = 'reserve';

        -- Log the restock
        INSERT INTO RestockLog (product_id, location, quantity_added, reason_id, updated_at)
        VALUES (productId, 'sales_floor', quantityChange, reasonId, NOW());
    END IF;

    -- If restocking reserve
    IF location = 'reserve' AND quantityChange > 0 THEN
        -- Update reserve stock
        UPDATE Stock
        SET quantity = quantity + quantityChange
        WHERE product_id = productId AND location = 'reserve';

        -- Log the restock
        INSERT INTO RestockLog (product_id, location, quantity_added, reason_id, updated_at)
        VALUES (productId, 'reserve', quantityChange, reasonId, NOW());
    END IF;
END;
//

DELIMITER ;
