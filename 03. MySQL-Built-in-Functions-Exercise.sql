USE `soft_uni`;

#1-1
SELECT `first_name`,`last_name` FROM `employees`
WHERE `first_name` LIKE "sa%"
ORDER BY `employee_id`;

#1-2
select `first_name`, `last_name`
from `employees`
where `first_name` regexp '^[Ss][Aa].*' 
order by `employee_id`;

#2-1
SELECT `first_name`, `last_name` FROM `employees`
WHERE `last_name` LIKE "%ei%"
ORDER BY `employee_id`;

#2-2
select `first_name`, `last_name`
from `employees`
where `last_name` regexp '.*[Ee][Ii].*'
order by `employee_id`;

#3
SELECT `first_name` FROM `employees`
WHERE (`department_id` IN(3,10))
AND 
(YEAR(`hire_date`) BETWEEN 1995 AND 2005)
ORDER BY `employee_id`;

SELECT `first_name` FROM `employees`
WHERE (`department_id` = 3 OR `department_id` = 10)
AND 
(YEAR(`hire_date`) BETWEEN 1995 AND 2005)
ORDER BY `employee_id`;

#4-1
SELECT `first_name`, `last_name` FROM `employees`
WHERE `job_title` NOT LIKE  "%engineer%"
ORDER BY `employee_id`;

#4-2
select `first_name`, `last_name`
from `employees`
where `job_title` regexp '[:space:.]*[Ee]ngineer[.:space:]*' = 0
order by `employee_id`;

#5
SELECT `name` FROM `towns`
WHERE char_length(`name`) IN (5,6)
ORDER BY `name`;

#5-2
SELECT `name` FROM `towns`
WHERE CHAR_LENGTH(`name`) = 5 OR CHAR_LENGTH(6)
ORDER BY `name`;

#5-3
select `name` 
from `towns`
where `name` regexp '^[[:alpha:][:space:]]{5,6}$' = 1
order by `name`;

#6-1
SELECT `town_id`, `name` FROM `towns`
WHERE `name` REGEXP "^[MKBEmkbe]"
ORDER BY `name`;

#6-2
select `town_id`, `name`
from `towns`
where left(`name`, 1) in ('m','k','b','e') #case insensitive
order by `name`;

#7
SELECT `town_id`, `name` FROM `towns`
WHERE `name` REGEXP "^[^RBDrbd]"
ORDER BY `name`;

#8-1
CREATE VIEW `v_employees_hired_after_2000` AS 
SELECT `first_name`, `last_name` FROM `employees`
WHERE YEAR(`hire_date`) > 2000;

SELECT * FROM `v_employees_hired_after_2000`;

#8-2
create view `v_employees_hired_after_2000` as
select `first_name`, `last_name`
from `employees`
where extract(year from `hire_date`) > 2000;

select * from `v_employees_hired_after_2000`;

#9-2
SELECT `first_name`, `last_name` FROM `employees`
WHERE CHAR_LENGTH(`last_name`) = 5;

#9-2
select `first_name`, `last_name`
from `employees`
where `last_name` regexp '^[[:space:][:alpha:]]{5}$' = 1;

#10-1
USE `geography`;

SELECT `country_name`, `iso_code` FROM `countries`
WHERE `country_name` LIKE "%A%A%A%"
ORDER BY `iso_code`;

#10-2
select `country_name`, `iso_code`
from `countries`
where `country_name` regexp
	'[[:space:]B-Zb-z\\-]*[Aa][[:space:]B-Zb-z\\-]*[Aa][[:space:]B-Zb-z\\-]*[Aa][[:space:]B-Zb-z\\-]*'
order by `iso_code`;

#11-1
SELECT 
	`peak_name`, 
	`river_name`,
	CONCAT(LOWER(`peak_name`), SUBSTRING(LOWER(`river_name`), 2)) AS `Mix`
FROM `peaks`,`rivers`
WHERE 
	RIGHT(`peak_name`, 1) = LEFT(`river_name`, 1)
ORDER BY `Mix`;

#11-2
select 
	`peak_name`,
	`river_name`,
    lower(concat(`peak_name`, substr(`river_name`, 2))) as `mix`
from `peaks`, `rivers`
where substr(`peak_name` from -1 for 1) = substr(`river_name` from 1 for 1)
order by `mix`;

#12
USE `diablo`;

SELECT 
	`name`, 
    DATE_FORMAT(`start`, "%Y-%m-%d") AS `start`
FROM `games`
WHERE YEAR(`start`) BETWEEN 2011 AND 2012
ORDER BY `start`, `name`
LIMIT 50;

#13
SELECT
	`user_name`,
	SUBSTRING(`email`, LOCATE("@", `email`) + 1) AS `email provider`
FROM `users` 
ORDER BY `email provider`, `user_name`;

#14
SELECT `user_name`, `ip_address` FROM `users`
WHERE `ip_address` LIKE "___.1%.%.___"
ORDER BY `user_name`;

#15
SELECT 
	`name` AS `game`,
    CASE 
		WHEN HOUR(`start`) >= 0 AND HOUR(`start`) < 12 THEN "Morning"
		WHEN HOUR(`start`) >= 12 AND HOUR(`start`) < 18 THEN "Afternoon"
		ELSE "Evening" 
    END AS `Part of the Day`,
    CASE 
		WHEN `duration` <= 3 THEN "Extra Short"
		WHEN `duration` <= 6 THEN "Short"
		WHEN `duration` <= 10 THEN "Long"
		ELSE "Extra Long"
    END AS `Duration`
FROM `games`;
    15. Show All Games with Duration16. Orders Table

15. Show All Game
#16
USE `orders`;

SELECT 
	`product_name`,
    `order_date`,
    ADDDATE(`order_date`, INTERVAL 3 DAY) AS `pay_due`,
    ADDDATE(`order_date`, INTERVAL 1 MONTH) AS `deliver_due`
FROM `orders`;

