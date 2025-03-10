CREATE SCHEMA `stc`;
USE `stc`;

CREATE TABLE `addresses`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL
);

CREATE TABLE `categories`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(10) NOT NULL
);

CREATE TABLE `clients`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `full_name` VARCHAR(50) NOT NULL,
    `phone_number` VARCHAR(20) NOT NULL
);

CREATE TABLE `drivers`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(30) NOT NULL,
    `last_name` VARCHAR(30) NOT NULL,
    `age` INT NOT NULL,
	`rating` FLOAT DEFAULT 5.5
);

CREATE TABLE `cars`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `make` VARCHAR(20) NOT NULL,
    `model` VARCHAR(20),
    `year` INT NOT NULL DEFAULT 0,
    `mileage` INT DEFAULT 0,
    `condition` CHAR(1) NOT NULL,
    `category_id` INT NOT NULL, 
    CONSTRAINT `fk_cars_categories`
    FOREIGN KEY (`category_id`)
    REFERENCES `categories`(`id`)    
);

CREATE TABLE `courses`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `from_address_id` INT NOT NULL,
    `start` DATETIME NOT NULL,
    `bill` DECIMAL(10, 2) DEFAULT 10,
    `car_id` INT NOT NULL,
    `client_id` INT NOT NULL,
    CONSTRAINT `fk_courses_addresses`
    FOREIGN KEY (`from_address_id`)
    REFERENCES `addresses`(`id`),
    CONSTRAINT `fk_courses_cars`
    FOREIGN KEY (`car_id`)
    REFERENCES `cars`(`id`),
    CONSTRAINT `fk_courses_clients`
    FOREIGN KEY (`client_id`)
    REFERENCES `clients`(`id`)
);

CREATE TABLE `cars_drivers`(
	`car_id` INT NOT NULL,
    `driver_id` INT NOT NULL,
    CONSTRAINT `pk_cars_drivers`
    PRIMARY KEY (`car_id`, `driver_id`),
    CONSTRAINT `fk_to cars`
    FOREIGN KEY (`car_id`)
    REFERENCES `cars`(`id`),
    CONSTRAINT `fk_to_drivers`
    FOREIGN KEY (`driver_id`)
    REFERENCES `drivers`(`id`)
);


#SECTION 2

#2
INSERT INTO `clients`(`full_name`, `phone_number`)(
	SELECT 
		CONCAT_WS(" ", `first_name`, `last_name`),
        CONCAT("(088) 9999", `id` * 2)
    FROM `drivers`
    WHERE `id` BETWEEN 10 AND 20
);

#3
UPDATE `cars`
SET `condition` = "C"
WHERE 
	(`mileage` >= 800000 OR `mileage` IS NULL) AND
    `year` <= 2010 AND
    `make` NOT LIKE "Mercedes-Benz";
    
#4
DELETE FROM `clients`
WHERE 
	`id` NOT IN (SELECT `client_id` FROM `courses`) AND
    CHAR_LENGTH(`full_name`) > 3;

#5
SELECT `make`, `model`, `condition`
FROM `cars`
ORDER BY `id`;

#6
SELECT 
	`first_name`,
    `last_name`,
    `make`,
    `model`,
    `mileage`
FROM `drivers` AS d
JOIN `cars_drivers` AS cd ON d.`id` = cd.`driver_id`
JOIN `cars` AS c ON c.`id` = cd.`car_id`
WHERE c.`mileage` IS NOT NULL
ORDER BY c.`mileage` DESC, d.`first_name`;

#7
SELECT 
	ca.`id` AS "car_id",
    ca.`make`,
    ca.`mileage`,
    COUNT(co.`id`) AS "count_of_courses",
    ROUND(AVG(co.`bill`), 2) AS "avg_bill"
FROM `cars` AS ca
LEFT JOIN `courses` AS co ON co.`car_id` = ca.`id`
GROUP BY ca.`id`
HAVING count_of_courses != 2
ORDER BY count_of_courses DESC, car_id;

#8
SELECT 
	cl.`full_name`,
    COUNT(co.`car_id`) AS "count_of_cars",
    SUM(co.`bill`) AS "total_sum"
FROM `clients` AS cl
JOIN `courses` AS co ON cl.`id` = co.`client_id`
WHERE cl.`full_name` LIKE "_a%"
GROUP BY cl.`id`
HAVING count_of_cars > 1
ORDER BY cl.`full_name`;

#9
SELECT 
	a.`name`,
    IF (HOUR(`start`) BETWEEN 6 AND 20, "Day", "Night") AS "day_time",
    co.`bill`,
    cl.`full_name`,
    ca.`make`,
    ca.`model`,
    cat.`name` AS "category_name"
FROM `courses` AS co
JOIN `addresses` AS a ON co.`from_address_id` = a.`id`
JOIN `clients` AS cl ON co.`client_id` = cl.`id`
JOIN `cars` AS ca ON co.`car_id` = ca.`id`
JOIN `categories` AS cat ON cat.`id` = ca.`category_id`
ORDER BY co.`id` ;


#SECTION 4

#10
DELIMITER $$
CREATE FUNCTION udf_courses_by_client (phone_num VARCHAR (20))
RETURNS INT 
DETERMINISTIC
BEGIN

DECLARE count_corses INT;
SET count_corses := (
		SELECT 
			COUNT(co.`id`)
		FROM `courses` AS  co
        JOIN `clients` AS cl ON co.`client_id` = cl.`id`
        WHERE cl.`phone_number` = phone_num
        GROUP BY co.`client_id`);

RETURN count_corses;

END$$

#11
DELIMITER $$
CREATE PROCEDURE udp_courses_by_address(address_name VARCHAR(100))
BEGIN 

SELECT 
	a.`name`,
    cl.`full_name` AS "full_names",
    (	CASE
		WHEN co.`bill` <= 20 THEN "Low"
        WHEN co.`bill` <= 30 THEN  "Medium"
        ELSE "High"
        END
    ) AS "level_of_bill",
    car.`make`,
    car.`condition`,
    cat.`name` AS "cat_name"
FROM `addresses` AS a
JOIN `courses` AS co ON co.`from_address_id` = a.`id`
JOIN `clients` AS cl ON cl.`id` = co.`client_id`
JOIN `cars` AS car ON car.`id` = co.`car_id`
JOIN `categories` AS cat ON car.`category_id` = cat.`id`
WHERE a.`name` LIKE address_name
ORDER BY car.`make`, cl.`full_name`;

END$$









