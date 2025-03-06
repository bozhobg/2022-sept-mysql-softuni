CREATE DATABASE `fsd`;

USE `fsd`;

CREATE TABLE `countries`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL
);

CREATE TABLE `towns`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL,
    `country_id` INT NOT NULL,
    CONSTRAINT fk_towns_countries
    FOREIGN KEY (`country_id`)
    REFERENCES `countries`(`id`)
);

CREATE TABLE `stadiums`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL,
	`capacity` INT NOT NULL,
    `town_id` INT NOT NULL,
    CONSTRAINT fk_stadiums_towns
    FOREIGN KEY (`town_id`)
    REFERENCES `towns`(`id`)
);


CREATE TABLE `teams`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL,
    `established` DATE NOT NULL,
    `fan_base` BIGINT(20) NOT NULL,
    `stadium_id` INT NOT NULL,
    CONSTRAINT fk_teams_stadiums
    FOREIGN KEY (`stadium_id`)
    REFERENCES `stadiums`(`id`)
);

CREATE TABLE `skills_data`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `dribbling` INT DEFAULT(0),
    `pace` INT DEFAULT(0),
    `passing` INT DEFAULT(0), 
    `shooting` INT DEFAULT(0),
    `speed` INT DEFAULT(0),
    `strength` INT DEFAULT(0)
);

CREATE TABLE `coaches`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(10) NOT NULL,
    `last_name` VARCHAR(20) NOT NULL,
    `salary` DECIMAL(10,2) NOT NULL DEFAULT(0),
    `coach_level` INT DEFAULT(0)
);

CREATE TABLE `players`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(10) NOT NULL,
    `last_name` VARCHAR(20) NOT NULL,
    `age` INT DEFAULT(0) NOT NULL, #not null needed ??
    `position` CHAR(1) NOT NULL, #ENUM("A","M","D") as string data type!
    `salary` DECIMAL(10,2) NOT NULL DEFAULT(0),
    `hire_date` DATETIME,
    `skills_data_id` INT NOT NULL,
    `team_id` INT,
    CONSTRAINT fk_players_skills_data
    FOREIGN KEY (`skills_data_id`)
    REFERENCES `skills_data`(`id`),
    CONSTRAINT fk_players_teams
    FOREIGN KEY (`team_id`)
    REFERENCES `teams`(`id`)
);


#COMPOSITE PK OF THE FKS
CREATE TABLE `players_coaches`(
	`player_id` INT,
    `coach_id` INT,
    CONSTRAINT fk_players_coachers_players
    FOREIGN KEY (`player_id`)
    REFERENCES `players`(`id`),
    CONSTRAINT fk_players_coachers_coaches
    FOREIGN KEY (`coach_id`)
    REFERENCES `coaches`(`id`)
);


#2
INSERT INTO `coaches`(`first_name`, `last_name`, `salary`, `coach_level`)(
SELECT 
	`first_name`, 
    `last_name`, 
    `salary`, 
	CHAR_LENGTH(`first_name`) FROM `players` AS p
WHERE age >= 45
);

#3
UPDATE `coaches` AS c
SET c.`coach_level` = c.`coach_level` + 1
WHERE 
	c.`id` IN (SELECT `coach_id` FROM `players_coaches`) AND 
    `first_name` LIKE "A%";  
    

#4
DELETE FROM `players` AS p
WHERE p.`age` >= 45;


#drop and insert again data

#5
SELECT `first_name`, `age`, `salary` FROM `players`
ORDER BY `salary` DESC;	

#6
SELECT 
	p.`id`, 
    CONCAT_WS(" ", p.`first_name`, p.`last_name`) AS "full_name", 
    p.`age`,
    p.`position`,
    p.`hire_date`
FROM `players` AS p
JOIN `skills_data` AS sd ON  sd.`id` = p.`skills_data_id`
WHERE 
	p.`age` < 23 AND
    p.`position` = "A" AND
    p.`hire_date` IS NULL AND
    sd.`strength` > 50 #JOIN W/ PLAYER SKILLS
ORDER BY `salary`, `age`;
    
#7
SELECT 
	t.`name`, 
    t.`established`,
    t.`fan_base`,
    COUNT(p.`team_id`) AS "count_of_players"
FROM `teams` AS t
LEFT JOIN `players` AS p ON t.`id` = p.`team_id`
GROUP BY t.`id`
ORDER BY count_of_players DESC, `fan_base` DESC;

#8
SELECT 
	MAX(sd.`speed`) AS "max_speed",
    tw.`name` AS "town_name"
FROM `skills_data` AS sd
RIGHT JOIN `players` AS p ON sd.`id` = p.`skills_data_id`
RIGHT JOIN `teams` AS t ON t.`id` = p.`team_id`
RIGHT JOIN `stadiums` AS s ON s.`id` = t.`stadium_id`
RIGHT JOIN `towns` AS tw ON tw.`id` = s.`town_id`
WHERE t.`name` != "Devify"
GROUP BY tw.`id`
ORDER BY max_speed DESC, tw.`name`;

#9
SELECT 
	c.`name`,
    COUNT(p.`id`) AS "total_count_of_players",
    SUM(p.`salary`) AS "total_sum_of_salaries"
FROM `countries` AS c
LEFT JOIN `towns` AS tw ON c.`id` = tw.`country_id`
LEFT JOIN `stadiums` AS s ON s.`town_id` = tw.`id`
LEFT JOIN `teams` AS te ON te.`stadium_id` = s.`id`
LEFT JOIN `players` AS p ON p.`team_id` = te.`id`
GROUP BY c.`id` 
ORDER BY total_count_of_players DESC, c.`name`;



#10
DELIMITER $$
CREATE FUNCTION udf_stadium_players_count(stadium_name VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (
		SELECT COUNT(p.`id`) 
		FROM `players` AS p
		RIGHT JOIN `teams` AS te ON p.`team_id` = te.`id`
		RIGHT JOIN `stadiums` AS s on te.`stadium_id` = s.`id`
		WHERE s.`name` = stadium_name
        GROUP BY s.`id`
    );
END$$



#11
DELIMITER $$
CREATE PROCEDURE udp_find_playmaker(min_dribble_points INT, team_name VARCHAR(45))
BEGIN
	SELECT 
		CONCAT_WS(" ", p.`first_name`, p.`last_name`) AS "full_name",
        p.`age`,
        p.`salary`,
        sd.`dribbling`,
        sd.`speed`,
        te.`name` AS "team_name"
	FROM `players` AS p
    JOIN `teams` AS te ON te.`id` = p.`team_id`
    JOIN `skills_data` AS sd ON sd.`id` = p.`skills_data_id`
    WHERE 
		sd.`dribbling` > min_dribble_points AND 
        te.`name` = team_name AND
		sd.`speed` > (SELECT AVG(`speed`) FROM `skills_data`)
    ORDER BY sd.`speed` DESC
    LIMIT 1;
END$$

CALL udp_find_playmaker(20, "Skyble");