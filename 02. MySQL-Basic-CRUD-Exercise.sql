#1
USE `soft_uni`;

SELECT `department_id`, `name`, `manager_id` FROM `departments`
ORDER BY `department_id`;

#2
SELECT `name` FROM `departments`
ORDER BY `department_id`;

#3
SELECT `first_name`, `last_name`,`salary` FROM `employees`
ORDER BY `employee_id`;

#4
SELECT `first_name`, `middle_name`, `last_name` FROM `employees`
ORDER BY `employee_id`;

#5
SELECT CONCAT(`first_name`, ".", `last_name`, "@softuni.bg") 
AS full_email_address
FROM `employees`;

#6
SELECT DISTINCT `salary` FROM `employees`;

#7
SELECT * FROM `employees`
WHERE `job_title` = "Sales Representative"
ORDER BY `employee_id`;

#8
SELECT `first_name`, `last_name`, `job_title` FROM `employees`
WHERE `salary` BETWEEN 20000 AND 30000
ORDER BY `employee_id`;

SELECT `first_name`, `last_name`, `job_title` FROM `employees`
WHERE `salary` >= 20000 AND `salary` <=30000
ORDER BY `employee_id`;

#9
SELECT CONCAT_WS(" ", `first_name`, `middle_name`, `last_name`) 
AS "Full Name"
FROM `employees`
WHERE `salary` IN (25000, 14000, 12500, 23600);

SELECT 
    CONCAT_WS(' ',
            `first_name`,
            `middle_name`,
            `last_name`) AS 'Full Name'
FROM
    `employees`
WHERE
    `salary` = 25000 OR `salary` = 14000
        OR `salary` = 12500
        OR `salary` = 23600;

#10
SELECT 	`first_name`, `last_name` 
FROM `employees`
WHERE `manager_id` IS NULL;

#11
SELECT `first_name`, `last_name`, `salary` 
FROM `employees`
WHERE `salary` > 50000
ORDER BY `salary` DESC;

#12
SELECT `first_name`, `last_name` FROM `employees`
ORDER BY `salary` DESC 
LIMIT 5;

#13
SELECT `first_name`, `last_name` FROM `employees`
WHERE `department_id` NOT IN (4);

#14
SELECT * FROM `employees`
ORDER BY 
	`salary` DESC,
    `first_name`,
    `last_name` DESC,
    `middle_name`;
    
#15
CREATE VIEW `v_employees_salaries` AS 
	SELECT `first_name`, `last_name`, `salary` FROM `employees`;

DESCRIBE  `v_first_last_name_salary`;

SELECT * FROM `v_first_last_name_salary`;

#16-1
CREATE VIEW `v_employees_job_titles` AS
    SELECT 
        CONCAT_WS(' ',
                `first_name`,
                `middle_name`,
                `last_name`) AS `full_name`,
        `job_title`
    FROM `employees`;
    
SELECT * FROM `v_employees_job_titles`;

#16-2
create view `v_employees_job_titles` as 
	select if (`middle_name` is null, 
		concat_ws(' ', `first_name`, `last_name`),
		concat_ws(' ', `first_name`, `middle_name`, `last_name`))
	from `employees`;

select * from `v_employees_job_titles`;

#17
SELECT DISTINCT `job_title` FROM `employees`
ORDER BY `job_title`;

#18
SELECT `project_id`, `name`, `description`, `start_date`, `end_date` 
FROM `projects`
ORDER BY `start_date`, `name`, `project_id`
LIMIT 10;

#19
SELECT `first_name`, `last_name`, `hire_date` FROM `employees`
ORDER BY `hire_date` DESC
LIMIT 7;

#20-1
UPDATE `employees`
SET `salary` = `salary` * 1.12
WHERE `department_id` IN (1, 2, 4, 11);

SELECT `salary` FROM `employees`;

#20-2
update `employees`
set `salary` = `salary` * 1.12
where `department_id` in (
	select `d`.`department_id`
	from `departments` as `d`
	where `d`.`name` in ('Engineering', 'Tool Design', 'Marketing', 'Information Services')
);

select `salary`
from `employees`;

#21
USE `geography`;

SELECT `peak_name` FROM `peaks`
ORDER BY `peak_name`;

#22-1
SELECT `country_name`, `population` FROM `countries`
WHERE `continent_code` = "EU" 
ORDER BY 
	`population` DESC,
    `country_name`
LIMIT 30;

#22-2
select `country_name`, `population`
from `countries`
where `continent_code` = (
	select `continent_code`
    from `continents`
    where `continent_name` like 'Europe'
    limit 1
) 
order by 
	`population` desc,
    `country_name`
limit 30;

#23-1
SELECT `country_name`, `country_code`, 
	IF (`currency_code` = "EUR", "Euro", "Not Euro") AS `currency`
FROM `countries`
ORDER BY `country_name`;

#23-2
select 
	`country_name`, 
	`country_code`, 
    (case 
		when `currency_code` like 'EUR' then 'Euro'
        else 'Not Euro'
	end) as `currency`
from `countries`
order by `country_name` asc;

#24
USE `diablo`;

SELECT `name` FROM `characters` ORDER BY `name`;

SHOW TABLES FROM `geography`;
