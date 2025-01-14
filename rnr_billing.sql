CREATE TABLE `rnr_billing` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(50) NOT NULL,
    `sender` VARCHAR(50) NOT NULL,
    `target_type` VARCHAR(50) NOT NULL,
    `target` VARCHAR(50) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `amount` INT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
