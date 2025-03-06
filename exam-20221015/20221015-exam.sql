DROP SCHEMA `restaurant_db`;
CREATE SCHEMA `restaurant_db`;
USE `restaurant_db`;

#SECTION1
#1

CREATE TABLE `products`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL UNIQUE,
    `type` VARCHAR(30) NOT NULL,
    `price` DECIMAL(10, 2) NOT NULL
);

CREATE TABLE `clients`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `birthdate` DATE NOT NULL,
    `card` VARCHAR(50),
    `review` TEXT
);

CREATE TABLE `tables`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `floor` INT NOT NULL,
    `reserved` BOOLEAN,
    `capacity` INT NOT NULL
);

CREATE TABLE `waiters`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `email` VARCHAR(50) NOT NULL,
    `phone` VARCHAR(50),
    `salary` DECIMAL(10,2)
);

CREATE TABLE `orders`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `table_id` INT NOT NULL,
    `waiter_id` INT NOT NULL,
    `order_time` TIME NOT NULL,
    `payed_status` BOOLEAN,
    CONSTRAINT `fk_orders_tables`
    FOREIGN KEY (`table_id`)
    REFERENCES `tables`(`id`),
    CONSTRAINT `fk_orders_waiters`
    FOREIGN KEY (`waiter_id`)
    REFERENCES `waiters`(`id`)
);

CREATE TABLE `orders_clients`(
	`order_id` INT,
    `client_id` INT,
    CONSTRAINT `fk_oc_orders`
    FOREIGN KEY (`order_id`)
    REFERENCES `orders`(`id`),
    CONSTRAINT `fk_oc_clients`
    FOREIGN KEY (`client_id`)
    REFERENCES `clients`(`id`)
);

CREATE TABLE `orders_products`(
	`order_id` INT,
    `product_id` INT,
    CONSTRAINT `fk_op_orders`
    FOREIGN KEY (`order_id`)
    REFERENCES `orders`(`id`),
    CONSTRAINT `fk_op_products`
    FOREIGN KEY (`product_id`)
    REFERENCES `products`(`id`)
);


#SECTION2

#2
INSERT INTO `products`(`name`, `type`, `price`)(
	SELECT
		CONCAT(`last_name`, " specialty"),
        "Cocktail",
        CEIL(`salary` * 0.01)
    FROM `waiters`
    WHERE `id` > 6
);

#3
UPDATE `orders`
SET `table_id` = `table_id` - 1
WHERE `id` BETWEEN 12 AND 23;

#4
DELETE FROM `waiters`
WHERE `id` NOT IN (
	SELECT DISTINCT `waiter_id`
    FROM `orders`
);


#SECTION 3

#5
SELECT
	`id`,
	`first_name`,
    `last_name`,
    `birthdate`,
    `card`,
    `review`
FROM `clients`
ORDER BY `birthdate` DESC, `id` DESC;

#6
SELECT 
	`first_name`,
    `last_name`,
    `birthdate`,
    `review`
FROM `clients`
WHERE 
	`card` IS NULL AND
    YEAR(`birthdate`) BETWEEN 1978 AND 1993
ORDER BY `last_name` DESC, `id`
LIMIT 5;

#7
SELECT 
	CONCAT(`last_name`, `first_name`, CHAR_LENGTH(`first_name`), "Restaurant")
    AS "username",
    REVERSE(SUBSTRING(`email`, 2, 12)) AS "password"
FROM `waiters`
WHERE `salary` IS NOT NULL 
ORDER BY `password` DESC;

SELECT * FROM `waiters`;

#8
SELECT 
	pr.`id`,
    pr.`name`,
    COUNT(opr.`order_id`) AS "count"
FROM `products` AS pr
LEFT JOIN `orders_products`  AS opr 
ON pr.`id` = opr.`product_id`
GROUP BY pr.`id`
HAVING `count` >= 5
ORDER BY `count` DESC, pr.`name`;

#9
SELECT 
	t.`id` AS "table_id",
    t.`capacity` AS "capacity",
    COUNT(oc.`client_id`) AS "count_clients",
    (
		CASE 
			WHEN t.`capacity` > COUNT(oc.`client_id`) THEN "Free seats"
            WHEN t.`capacity` = COUNT(oc.`client_id`) THEN "Full"
            WHEN  t.`capacity` < COUNT(oc.`client_id`) THEN "Extra seats"
        END
    ) AS "availability"
FROM `tables` AS t
JOIN `orders` AS o ON o.`table_id` = t.`id`
JOIN `orders_clients` AS oc ON oc.`order_id` = o.`id`
WHERE t.`floor` = 1
GROUP BY t.`id`
ORDER BY table_id DESC;


#SECTION 4

#10
DELIMITER $$
CREATE FUNCTION udf_client_bill(full_name VARCHAR(50))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	RETURN (
		SELECT SUM(pr.`price`) 
        FROM `clients` AS cl
        LEFT JOIN `orders_clients` AS oc ON oc.`client_id` = cl.`id`
        LEFT JOIN `orders` AS o ON o.`id` = oc.`order_id`
        LEFT JOIN `orders_products` AS op ON op.`order_id` = o.`id`
        LEFT JOIN `products` AS pr ON pr.`id` = op.`product_id`
        WHERE full_name = CONCAT_WS(" ", cl.`first_name`, cl.`last_name`)
        GROUP BY cl.`id`
    );
END$$

#11
DELIMITER $$
CREATE PROCEDURE udp_happy_hour(for_type VARCHAR(50))
BEGIN
	UPDATE `products`
    SET `price` = `price` * 0.80
    WHERE `type` = for_type AND
		`price` >= 10.00;
END$$






















