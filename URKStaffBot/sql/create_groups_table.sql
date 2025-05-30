CREATE TABLE IF NOT EXISTS `urk_groups` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` VARCHAR(50) NOT NULL,
    `group_name` VARCHAR(50) NOT NULL,
    `added_by` VARCHAR(50) NOT NULL,
    `added_date` DATETIME NOT NULL,
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_group_name` (`group_name`),
    UNIQUE KEY `unique_user_group` (`user_id`, `group_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci; 