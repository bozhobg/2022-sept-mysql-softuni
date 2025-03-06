DROP SCHEMA softuni_stores_system;
CREATE SCHEMA softuni_stores_system;
USE softuni_stores_system;

CREATE TABLE `pictures`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `url` VARCHAR(100) NOT NULL,
    `added_on` DATETIME NOT NULL
);

CREATE TABLE `categories`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `products`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(40) NOT NULL UNIQUE,
    `best_before` DATE,
    `price` DECIMAL(10, 2) NOT NULL,
    `description` TEXT,
    `category_id` INT NOT NULL,
    `picture_id` INT NOT NULL,
    CONSTRAINT `fk_products_categories`
    FOREIGN KEY (`category_id`)
    REFERENCES `categories`(`id`),
    CONSTRAINT `fk_products_pictures`
    FOREIGN KEY (`picture_id`)
    REFERENCES `pictures`(`id`)
);

CREATE TABLE `towns`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE `addresses`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `town_id` INT NOT NULL,
    CONSTRAINT `fk_addresses_towns`
    FOREIGN KEY (`town_id`)
    REFERENCES `towns`(`id`)
);

CREATE TABLE `stores`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(20) NOT NULL UNIQUE,
    `rating` FLOAT NOT NULL,
    `has_parking` BOOLEAN DEFAULT FALSE,
    `address_id` INT NOT NULL,
    CONSTRAINT `fk_stores_addresses`
    FOREIGN KEY (`address_id`)
    REFERENCES `addresses`(`id`)
);

CREATE TABLE `products_stores`(
	`product_id` INT NOT NULL,
    `store_id` INT NOT NULL,
    CONSTRAINT `pk_comp`
    PRIMARY KEY (`product_id`, `store_id`),
    CONSTRAINT `fk_mapto_products`
    FOREIGN KEY (`product_id`)
    REFERENCES `products`(`id`),
    CONSTRAINT `fk_mapto_stores`
    FOREIGN KEY (`store_id`)
    REFERENCES `stores`(`id`)
);

CREATE TABLE `employees`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(15) NOT NULL,
    `middle_name` CHAR(1),
    `last_name` VARCHAR(20) NOT NULL,
    `salary` DECIMAL(19, 2) DEFAULT 0,
    `hire_date` DATE NOT NULL,
    `manager_id` INT,
    `store_id` INT NOT NULL,
    CONSTRAINT `fk_selfref_manager`
    FOREIGN KEY (`manager_id`)
    REFERENCES `employees`(`id`),
    CONSTRAINT `fk_employees_stores`
    FOREIGN KEY (`store_id`)
    REFERENCES `stores`(`id`)
);


#SECTION 2

#2
INSERT INTO `products_stores`(`product_id`, `store_id`)(
	SELECT `id` AS "product_id",
			1 AS "store_id"
	FROM `products`
	WHERE `id` NOT IN (
		SELECT `product_id`
		FROM `products_stores`)
);

#3
UPDATE `employees` AS e
LEFT JOIN `stores` AS st ON e.`store_id` = st.`id`
SET `manager_id` = 3, `salary` = `salary` - 500
WHERE 
	(st.`name` NOT IN ("Cardguard", "Veribet")) AND
	(YEAR(e.`hire_date` ) > 2003);

#4   
DELETE e FROM `employees` AS e
JOIN `employees` AS em ON em.`id` = e.`manager_id`
WHERE e.`salary` >= 6000;


#SECTION 3

#5
SELECT 
	`first_name`,
    `middle_name`,
    `last_name`,
    `salary`,
    `hire_date`
FROM `employees`
ORDER BY `hire_date` DESC;

#6
SELECT
	pr.`name`,
    pr.`price`,
    pr.`best_before`,
    CONCAT(SUBSTRING(pr.`description`, 1, 10), "...") AS "short_description",
    pi.`url`
FROM `products` AS pr
JOIN `pictures` AS pi ON pi.`id` = pr.`picture_id`
WHERE 
	CHAR_LENGTH(pr.`description`) > 100 AND
    YEAR(pi.`added_on`) < 2019 AND
    pr.`price` > 20
ORDER BY pr.`price` DESC;

#7
SELECT 
	st.`name`,
    COUNT(ps.`product_id`) AS "product_count",
    ROUND(AVG(pr.`price`), 2) AS "avg"
FROM `stores` AS st
LEFT JOIN `products_stores` AS ps ON ps.`store_id` = st.`id`
LEFT JOIN `products` AS pr ON pr.`id` = ps.`product_id`
GROUP BY st.`id`
ORDER BY `product_count` DESC, `avg` DESC, st.`id`;

#8
SELECT 
	CONCAT_WS(" ", e.`first_name`, e.`last_name`) AS "Full_name",
    st.`name` AS "Store_name",
    ad.`name` AS "Address",
    e.`salary` AS "Salary"
FROM `employees` AS e
JOIN `stores` AS st ON e.`store_id` = st.`id`
JOIN `addresses` AS ad ON st.`address_id` = ad.`id`
WHERE 
	e.`salary` < 4000 AND 
    ad.`name` LIKE "%5%" AND
    CHAR_LENGTH(st.`name`) > 8 AND
    e.`last_name` LIKE "%n%";
    
#9
SELECT 
	REVERSE(st.`name`) AS "reversed_name",
    CONCAT_WS("-", UPPER(t.`name`), ad.`name`) AS "full_address",
    COUNT(e.`id`) AS "employee_count"
FROM `stores` AS st
JOIN `addresses` AS ad ON st.`address_id` = ad.`id`
JOIN `towns` AS t ON t.`id` = ad.`town_id`
JOIN `employees` AS e ON e.`store_id` = st.`id`
GROUP BY st.`id`
HAVING `employee_count` >= 1
ORDER BY `full_address`;

#SECTION 4
DELIMITER $$
CREATE FUNCTION udf_top_paid_employee_by_store(store_name VARCHAR(50))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
	DECLARE full_name VARCHAR(50);
	DECLARE experience INT;
    DECLARE employee_id_max_paid INT;
	
	SET employee_id_max_paid := (
			SELECT 
				e.`id`
			FROM `employees` AS e
			JOIN `stores` AS st ON st.`id` = e.`store_id`
			WHERE st.`name` = store_name
			GROUP BY e.`id`
			ORDER BY `salary` DESC
			LIMIT 1
			);
            
	SET full_name := (
			SELECT 
				CONCAT(`first_name`, " ", `middle_name`, ". ", `last_name`)
			FROM `employees` AS e
			WHERE e.`id` = employee_id_max_paid 
		);
            
	SET experience := (
			SELECT (YEAR("2020-10-18") - YEAR(`hire_date`))
            FROM `employees` AS e
            WHERE e.`id` = employee_id_max_paid
		);
            
		RETURN CONCAT_WS(" ", full_name, "works in store for", experience, "years");
			
END$$

#11
DELIMITER $$
CREATE PROCEDURE udp_update_product_price (address_name VARCHAR (50))
BEGIN 
	DECLARE price_increase DECIMAL(10,2);
	
    SET price_increase := IF(SUBSTRING(address_name, 1, 1) = "0", 100, 200);
    
    UPDATE `products` AS pr
    JOIN `products_stores` AS ps ON pr.`id` = ps.`product_id`
    JOIN `stores` AS st ON st.`id` = ps.`store_id`
	JOIN `addresses` AS ad ON ad.`id` = st.`address_id`
	SET pr.`price` = pr.`price` + price_increase
    WHERE ad.`name` = address_name;

END$$





