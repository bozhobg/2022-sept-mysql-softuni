DROP SCHEMA sgd;

CREATE SCHEMA sgd;
USE sgd;


CREATE TABLE `addresses`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL
);

CREATE TABLE `categories`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(10) NOT NULL
);

CREATE TABLE `offices`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `workspace_capacity` INT NOT NULL,
    `website` VARCHAR(50),
    `address_id` INT NOT NULL,
    CONSTRAINT `fk_offices_addresses`
    FOREIGN KEY (`address_id`)
    REFERENCES `addresses`(`id`)
);

CREATE TABLE `employees`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(30) NOT NULL,
    `last_name` VARCHAR(30) NOT NULL,
    `age` INT NOT NULL,
    `salary` DECIMAL(10, 2) NOT NULL,
    `job_title` VARCHAR(20) NOT NULL,
    `happiness_level` CHAR(1) NOT NULL #L,N,H
);

CREATE TABLE `teams`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(40) NOT NULL,
    `office_id` INT NOT NULL,
    `leader_id` INT NOT NULL UNIQUE,
    CONSTRAINT `fk_teams_offices`
    FOREIGN KEY (`office_id`)
    REFERENCES `offices`(`id`),
    CONSTRAINT `fk_teams_emoployees`
    FOREIGN KEY (`leader_id`)
    REFERENCES `employees`(`id`)
);

CREATE TABLE `games`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `description` TEXT,
    `rating` FLOAT NOT NULL DEFAULT 5.5,
    `budget` DECIMAL(10, 2) NOT NULL,
    `release_date` DATE,
    `team_id` INT NOT NULL,
    CONSTRAINT `fk_games_teams`
    FOREIGN KEY (`team_id`)
    REFERENCES `teams`(`id`)
);

CREATE TABLE `games_categories`(
	`game_id` INT NOT NULL,
    `category_id` INT NOT NULL,
    CONSTRAINT `pk_games_categories`
    PRIMARY KEY (`game_id`, `category_id`)
);

ALTER TABLE `games_categories`
ADD CONSTRAINT `fk_to_games`
FOREIGN KEY (`game_id`)
REFERENCES `games`(`id`),
ADD CONSTRAINT `fk_to_categories`
FOREIGN KEY (`category_id`)
REFERENCES `categories`(`id`);


#SECTION 2

#2
INSERT INTO `games`(`name`, `rating`, `budget`, `team_id`)(
	SELECT
		REVERSE(LOWER(SUBSTRING(`name`, 2))),
		`id`,
		`leader_id` * 1000,
		`id`
	FROM `teams` AS t
	WHERE `id` BETWEEN 1 AND 9 
);

#3
UPDATE `employees` AS e
JOIN `teams` AS t ON t.`leader_id` = e.`id`
SET `salary` = `salary` + 1000
WHERE e.`age` <= 40 AND `salary` < 5000;

#4
DELETE g
FROM `games` AS g
LEFT JOIN `games_categories` AS gc ON g.`id` = gc.`game_id`
WHERE g.`release_date` IS NULL AND gc.`category_id` IS NULL;


#SECTION 3

#5
SELECT `first_name`, `last_name`, `age`, `salary`, `happiness_level`
FROM `employees`
ORDER BY `salary`, `id`;

#6
SELECT
	t.`name` AS "team_name",
    a.`name` AS "address_name",
    CHAR_LENGTH(a.`name`)AS "count_of_characters" #address name
FROM `teams` AS t
JOIN `offices` AS o ON t.`office_id` = o.`id`
JOIN `addresses` AS a ON a.`id` = o.`address_id`
WHERE o.`website` IS NOT NULL
ORDER BY team_name, address_name;

#7
SELECT 
	c.`name`,
    COUNT(*) AS "games_count",
    ROUND(AVG(g.`budget`), 2) AS "avg_budget",
    MAX(g.`rating`) AS "max_rating"
FROM `categories` AS c
JOIN `games_categories` AS gc ON c.`id` = gc.`category_id`
JOIN `games` AS g ON g.`id` = gc.`game_id`
GROUP BY c.`id`
HAVING max_rating >= 9.5
ORDER BY games_count DESC, c.`name`;

#8
SELECT 
	g.`name`,
    g.`release_date`, 
    CONCAT(SUBSTRING(g.`description`, 1, 10), "...") AS "summary", 
	CONCAT("Q", QUARTER(g.`release_date`)) AS "quarter", 
    t.`name` AS "team_name"
FROM `games` AS g
JOIN `teams` AS t ON g.`team_id` = t.`id`
WHERE 
	YEAR(`release_date`) = 2022 AND
	g.`name` LIKE "%2" AND
	MONTH(`release_date`) % 2 = 0
ORDER BY `quarter`;

#9
SELECT
	g.`name`,
	(IF (g.`budget` < 50000, "Normal budget", "Insufficient budget")
	) AS "budget_level",
    t.`name` AS "team_name",
    a.`name` AS "address_name"
FROM `games` AS g
JOIN `teams` AS t ON g.`team_id` = t.`id`
JOIN `offices` AS o ON o.`id` = t.`office_id`
JOIN `addresses` AS a ON o.`address_id` = a.`id`
WHERE 
	g.`id` NOT IN (SELECT `game_id` FROM `games_categories`) AND 
    g.`release_date` IS NULL
ORDER BY g.`name`;


#SECTION 4

#10
DELIMITER $$
CREATE FUNCTION udf_game_info_by_name (game_name VARCHAR (20))
RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE team_name VARCHAR(40);
    DECLARE address_text VARCHAR(50);
    
    SET team_name := (
		SELECT t.`name`
        FROM `games` AS g
        JOIN `teams` AS t ON g.`team_id` = t.`id`
        WHERE g.`name` = game_name
    );
    
    SET address_text := (
		SELECT a.`name`
		FROM `addresses` AS a
        JOIN `offices` AS o ON o.`address_id` = a.`id`
        JOIN `teams` AS t ON t.`office_id` = o.`id`
        WHERE t.`name` = team_name
    );
    
	RETURN CONCAT_WS(" ", "The", game_name, "is developed by a", team_name, "in an office with an address", address_text);

END$$

#11
DELIMITER $$
CREATE PROCEDURE udp_update_budget (min_game_rating FLOAT)
BEGIN 
	UPDATE `games`
    SET 
		`budget` = `budget` + 100000,
		`release_date` = DATE_ADD(`release_date`, INTERVAL 1 YEAR)
	WHERE 
		`id` NOT IN (SELECT `game_id` FROM `games_categories`) AND
        `rating` > min_game_rating AND
        `release_date` IS NOT NULL;
END$$





