#1
SELECT `employee_id`, 
	CONCAT_WS(" ", `first_name`, `last_name`) AS `full_name`, 
    `d`.`department_id`,
    `d`.`name`
FROM `employees` AS `e`
INNER JOIN `departments` AS `d`
ON `e`.`employee_id` = `d`.`manager_id`
ORDER BY `employee_id`
LIMIT 5;

SELECT 
	`employee_id`,
	CONCAT_WS(" ", `first_name`, `middle_name`, `last_name`) AS `full_name`,
    `d`.`department_id`,
    `d`.`name` AS `department name`
FROM `employees` AS `e`
RIGHT JOIN `departments` AS `d`
ON `d`.`manager_id` = `e`.`employee_id`
ORDER BY `employee_id`
LIMIT 5;

#2
SELECT 
	`a`.`town_id`,
    `t`.`name` AS `town_name`,
    `address_text`
FROM `addresses` AS `a`
JOIN `towns` AS `t`
ON `t`.`town_id` = `a`.`town_id`
WHERE `name` = "San Francisco" 
		OR `name` = "Sofia" 
		OR `name` = "Carnation"
ORDER BY `town_id`, `address_id`;

#3-1
SELECT 
	`employee_id`,
    `first_name`,
    `last_name`,
    `department_id`,
    `salary`
FROM `employees` AS `e`
WHERE `e`.`manager_id` IS NULL;

#3-2
select 
	`employee_id`,
	`first_name`,
	`last_name`,
	`department_id`,
	`salary`
from (
	select *
	from `employees`
	where `manager_id` is null
) as `employees_without_manager`;


#4

SELECT COUNT(`e`.`employee_id`) AS `count`
FROM `employees` AS `e`
WHERE `salary` > (
	SELECT AVG(`salary`) AS `average_salary`
    FROM `employees`
);
