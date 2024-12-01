-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Dec 01, 2024 at 10:15 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `groceryproject`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AdjustStock` (IN `productId` INT, IN `location` ENUM('sales_floor','reserve'), IN `quantityChange` INT)   BEGIN
    DECLARE current_reserve_quantity INT;

    -- If restocking sales floor
    IF location = 'sales_floor' AND quantityChange > 0 THEN
        -- Get the current reserve stock
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
        INSERT INTO RestockLog (product_id, location, quantity_added, updated_at)
        VALUES (productId, 'sales_floor', quantityChange, NOW());
    END IF;

    -- If restocking reserve
    IF location = 'reserve' AND quantityChange > 0 THEN
        UPDATE Stock
        SET quantity = quantity + quantityChange
        WHERE product_id = productId AND location = 'reserve';

        -- Log the restock
        INSERT INTO RestockLog (product_id, location, quantity_added, updated_at)
        VALUES (productId, 'reserve', quantityChange, NOW());
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `betterrestocklog`
-- (See below for the actual view)
--
CREATE TABLE `betterrestocklog` (
`log_id` int(11)
,`product_id` int(11)
,`name` varchar(100)
,`location` enum('sales_floor','reserve')
,`quantity_added` int(11)
,`updated_at` timestamp
);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `category_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`category_id`, `name`, `description`) VALUES
(1, 'Dairy', 'Milk, cheese, yogurt, and other dairy products'),
(2, 'Meat', 'All types of meats and poultry'),
(3, 'Shelf Foods', 'Non-perishable items like canned goods, pasta, etc.'),
(4, 'Produce', 'Fresh fruits and vegetables'),
(5, 'Frozen Foods', 'Frozen meals and products');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `sku` varchar(50) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `name`, `category_id`, `sku`, `price`, `created_at`, `updated_at`) VALUES
(1, 'Whole Milk', 1, 'DAIRY-001', 3.50, '2024-10-30 05:43:54', '2024-10-30 05:43:54'),
(2, 'Chicken Breast', 2, 'MEAT-001', 5.00, '2024-10-30 05:43:54', '2024-10-30 05:43:54'),
(3, 'Canned Beans', 3, 'SHELF-001', 1.25, '2024-10-30 05:43:54', '2024-10-30 05:43:54'),
(4, 'Apples', 4, 'PROD-001', 0.75, '2024-10-30 05:43:54', '2024-10-30 05:43:54'),
(5, 'Frozen Pizza', 5, 'FROZEN-001', 4.00, '2024-10-30 05:43:54', '2024-10-30 05:43:54');

-- --------------------------------------------------------

--
-- Stand-in structure for view `productstockoverview`
-- (See below for the actual view)
--
CREATE TABLE `productstockoverview` (
`product_id` int(11)
,`product_name` varchar(100)
,`sales_floor_quantity` decimal(32,0)
,`sales_floor_last_updated` timestamp
,`reserve_quantity` decimal(32,0)
,`reserve_last_updated` timestamp
);

-- --------------------------------------------------------

--
-- Table structure for table `restocklog`
--

CREATE TABLE `restocklog` (
  `log_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `location` enum('sales_floor','reserve') NOT NULL,
  `quantity_added` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `restocklog`
--

INSERT INTO `restocklog` (`log_id`, `product_id`, `location`, `quantity_added`, `updated_at`) VALUES
(2, 1, 'sales_floor', 10, '2024-12-01 09:10:36');

-- --------------------------------------------------------

--
-- Table structure for table `stock`
--

CREATE TABLE `stock` (
  `stock_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `location` enum('sales_floor','reserve') NOT NULL,
  `quantity` int(11) DEFAULT 0,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `stock`
--

INSERT INTO `stock` (`stock_id`, `product_id`, `location`, `quantity`, `last_updated`) VALUES
(1, 1, 'sales_floor', 30, '2024-12-01 09:10:36'),
(2, 1, 'reserve', 60, '2024-12-01 09:10:36'),
(3, 2, 'sales_floor', 15, '2024-10-30 05:43:54'),
(4, 2, 'reserve', 30, '2024-10-30 05:43:54'),
(5, 3, 'sales_floor', 40, '2024-10-30 05:43:54'),
(6, 3, 'reserve', 80, '2024-10-30 05:43:54'),
(7, 4, 'sales_floor', 25, '2024-10-30 05:43:54'),
(8, 4, 'reserve', 60, '2024-10-30 05:43:54'),
(9, 5, 'sales_floor', 10, '2024-10-30 05:43:54'),
(10, 5, 'reserve', 20, '2024-10-30 05:43:54');

-- --------------------------------------------------------

--
-- Structure for view `betterrestocklog`
--
DROP TABLE IF EXISTS `betterrestocklog`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `betterrestocklog`  AS SELECT `rl`.`log_id` AS `log_id`, `rl`.`product_id` AS `product_id`, `p`.`name` AS `name`, `rl`.`location` AS `location`, `rl`.`quantity_added` AS `quantity_added`, `rl`.`updated_at` AS `updated_at` FROM (`restocklog` `rl` join `products` `p` on(`rl`.`product_id` = `p`.`product_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `productstockoverview`
--
DROP TABLE IF EXISTS `productstockoverview`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `productstockoverview`  AS SELECT `p`.`product_id` AS `product_id`, `p`.`name` AS `product_name`, coalesce(sum(case when `s`.`location` = 'sales_floor' then `s`.`quantity` end),0) AS `sales_floor_quantity`, max(case when `s`.`location` = 'sales_floor' then `s`.`last_updated` end) AS `sales_floor_last_updated`, coalesce(sum(case when `s`.`location` = 'reserve' then `s`.`quantity` end),0) AS `reserve_quantity`, max(case when `s`.`location` = 'reserve' then `s`.`last_updated` end) AS `reserve_last_updated` FROM (`products` `p` left join `stock` `s` on(`p`.`product_id` = `s`.`product_id`)) GROUP BY `p`.`product_id`, `p`.`name` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD UNIQUE KEY `sku` (`sku`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `restocklog`
--
ALTER TABLE `restocklog`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `stock`
--
ALTER TABLE `stock`
  ADD PRIMARY KEY (`stock_id`),
  ADD KEY `product_id` (`product_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `restocklog`
--
ALTER TABLE `restocklog`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `stock`
--
ALTER TABLE `stock`
  MODIFY `stock_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL;

--
-- Constraints for table `restocklog`
--
ALTER TABLE `restocklog`
  ADD CONSTRAINT `restocklog_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE;

--
-- Constraints for table `stock`
--
ALTER TABLE `stock`
  ADD CONSTRAINT `stock_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
