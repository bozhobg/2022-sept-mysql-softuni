DROP SCHEMA `instd`;
CREATE SCHEMA `instd`;
USE `instd`;

#SECTION 1
#1

CREATE TABLE `users`(
	`id` INT PRIMARY KEY,
    `username` VARCHAR(30) NOT NULL UNIQUE,
    `password` VARCHAR(30) NOT NULL,
    `email` VARCHAR(50) NOT NULL,
    `gender` CHAR(1) NOT NULL,
    `age` INT NOT NULL,
    `job_title` VARCHAR(40) NOT NULL,
    `ip` VARCHAR(30) NOT NULL
);

CREATE TABLE `addresses`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `address` VARCHAR(30) NOT NULL,
    `town` VARCHAR(30) NOT NULL,
    `country` VARCHAR(30) NOT NULL,
    `user_id` INT NOT NULL,
    CONSTRAINT `fk_addresses_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `users`(`id`)
);

CREATE TABLE `photos`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `description` TEXT NOT NULL,
    `date` DATETIME NOT NULL,
    `views` INT DEFAULT 0 NOT NULL
);

CREATE TABLE `comments`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `comment` VARCHAR(255) NOT NULL,
    `date` DATETIME NOT NULL,
    `photo_id` INT NOT NULL,
    CONSTRAINT `fk_comments_photos`
    FOREIGN KEY (`photo_id`)
    REFERENCES `photos`(`id`)
);

CREATE TABLE `users_photos`(
	`user_id` INT NOT NULL,
    `photo_id` INT NOT NULL,
    CONSTRAINT `fk_mapto_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `users`(`id`),
    CONSTRAINT `fk_mapto_photos`
    FOREIGN KEY (`photo_id`)
    REFERENCES `photos`(`id`)
);

CREATE TABLE `likes`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `photo_id` INT,
    `user_id` INT,
    CONSTRAINT `fk_likes_mapto_photos`
    FOREIGN KEY (`photo_id`)
    REFERENCES `photos`(`id`),
    CONSTRAINT `fk_likes_mapto_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `users`(`id`)
);


#SECTION2

#2
INSERT INTO `addresses`(`address`, `town`, `country`, `user_id`)
(	
	SELECT 
		`username`,
        `password`,
        `ip`,
        `age`
	FROM `users`
	WHERE `gender` = "M"
);

#3
UPDATE `addresses`
SET `country` = (
		CASE 
			WHEN LEFT(`country`, 1) = "B" THEN "Blocked"
            WHEN LEFT(`country`, 1) = "T" THEN "Test"
            WHEN LEFT(`country`, 1) = "P" THEN "In Progress"
            ELSE `country`
        END
	);
    
#4
DELETE FROM `addresses`
WHERE `id` % 3 = 0;



#SECTION3

#5
SELECT 
	`username`,
    `gender`,
    `age`
FROM `users`
ORDER BY `age` DESC, `username`;

#6
SELECT 
	p.`id`,
    p.`date` AS "date_and_time",
    p.`description`,
    COUNT(*) AS "commentsCount"
FROM `photos` AS p
LEFT JOIN `comments` AS c ON c.`photo_id` = p.`id`
GROUP BY p.`id`
ORDER BY `commentsCount` DESC, p.`id`
LIMIT 5;

#7
SELECT 
	CONCAT_WS(" ", up.`user_id`, u.`username`),
    u.`email`
FROM `users_photos` AS up
JOIN `users` AS u ON u.`id` = up.`user_id`
WHERE up.`user_id` = up.`photo_id`
ORDER BY u.`id`;

#8
SELECT 
	p.`id`,
    (	SELECT COUNT(`id`) FROM `likes` AS  l 
        WHERE l.`photo_id` = p.`id`
	) AS "likes_count",
    (	SELECT COUNT(`id`) FROM `comments` AS c
        WHERE c.`photo_id` = p.`id`
     ) AS "comments_count"
    FROM `photos` AS p
    ORDER BY `likes_count` DESC, `comments_count` DESC, p.`id`;
    
#9
SELECT 
	CONCAT(LEFT(`description`, 30), "...") AS "summary",
    `date`
FROM `photos`
WHERE DAY(`date`) = 10
ORDER BY `date` DESC;


#SECTION4 

#10
DELIMITER $$
CREATE FUNCTION udf_users_photos_count(username VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN 
		(SELECT COUNT(up.`photo_id`) FROM `users_photos` AS up
        RIGHT JOIN `users` AS u ON u.`id` = up.`user_id`
        WHERE u.`username` = username
        GROUP BY up.`user_id`);        
END$$

#11
DELIMITER $$
CREATE PROCEDURE udp_modify_user(address VARCHAR(30), town VARCHAR(30))
BEGIN
	UPDATE `users` AS u
    JOIN `addresses` AS ad ON ad.`user_id` = u.`id`
    SET `age` = `age` + 10
    WHERE ad.`address` = address AND ad.`town` = town;
END$$
















