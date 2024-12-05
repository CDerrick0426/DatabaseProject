CREATE TABLE RestockLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    location ENUM('sales_floor', 'reserve') NOT NULL,
    quantity_added INT NOT NULL,
    reason_id INT NOT NULL,
    updated_at DATETIME NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (reason_id) REFERENCES RestockReasons(reason_id)
);