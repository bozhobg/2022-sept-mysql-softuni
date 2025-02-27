USE `soft_uni`;

#01

SELECT 
	`employee_id`,
    `job_title`,
    `e`.`address_id`,
    `address_text`
FROM `employees` AS `e`
JOIN `addresses` AS `a`
ON `e`.`address_id` = `a`.`address_id`
ORDER BY `address_id` ASC
LIMIT 5;



#2

SELECT 
	`first_name`,
    `last_name`,
    `t`.`name` AS `town`,
    `a`.`address_text`
FROM `employees` AS `e`
JOIN `addresses` AS `a`
ON `e`.`address_id` = `a`.`address_id`
JOIN `towns` AS `t`
ON `a`.`town_id` = `t`.`town_id`
ORDER BY `first_name` ASC, `last_name`
LIMIT 5;

#3
SELECT 
	`employee_id`,
    `first_name`,
    `last_name`,
    `d`.`name` AS `department_name`
FROM `employees` AS `e`
JOIN `departments` AS `d`
ON `d`.`department_id` = `e`.`department_id`
WHERE `d`.`name` = "Sales" 
ORDER BY `employee_id` DESC;


#4
SELECT 
	`employee_id`,
    `first_name`,
    `salary`,
    `d`.`name` AS `department_name`
FROM `employees` AS `e`
JOIN `departments` AS `d`
ON `e`.`department_id` = `d`.`department_id`
WHERE `salary` > 15000
ORDER BY `d`.`department_id` DESC
LIMIT 5;

#5-1
SELECT 
	`e`.`employee_id`,
    `first_name`
FROM `employees` AS `e`
LEFT JOIN `employees_projects` AS `e_p`
ON `e`.`employee_id` = `e_p`.`employee_id`
WHERE `e_p`.`project_id` IS NULL
ORDER BY `employee_id` DESC
LIMIT 3;

#5-2
select 
	`e`.`employee_id`,
	`first_name`
from `employees` as `e`
where `e`.`employee_id` not in (
	select `ep`.`employee_id`
	from `employees_projects` as `ep`
)
order by `employee_id` desc
limit 3;

#6
SELECT
	`first_name`,
    `last_name`,
    `hire_date`,
    d.`name` AS `dept_name`
FROM `employees` AS e
JOIN `departments` AS d
ON e.`department_id` = d.`department_id`
WHERE 
	`hire_date` > "1999-01-01"
	AND d.`name` IN ("Finance", "Sales")
ORDER BY `hire_date`;



#7
SELECT
	ep.`employee_id`,
    e.`first_name`,
    p.`name` AS project_name
FROM `employees_projects` AS ep
JOIN `employees` AS e
ON e.`employee_id` = ep.`employee_id`
JOIN `projects` AS p
ON p.`project_id` = ep.`project_id`
WHERE p.`start_date` > 2002-08-13 AND p.`end_date` IS NULL
ORDER BY e.`first_name`, p.`name`
LIMIT 5;



#8
SELECT 
	ep.`employee_id`,
    e.`first_name`,
    (CASE 
    WHEN YEAR(p.`start_date`) >= 2005 THEN NULL
    ELSE p.`name`
    END) AS project_name
FROM `employees_projects` AS ep
JOIN `employees` AS e
ON e.`employee_id` = ep.`employee_id`
JOIN `projects` AS p
ON p.`project_id` = ep.`project_id`
WHERE ep.`employee_id` = 24
ORDER BY `project_name`;



#9-1
SELECT 
	e.`employee_id`,
    e.`first_name`,
    e.`manager_id`,
    em.`first_name` AS `manager_name`
FROM `employees` AS e
JOIN `employees` AS em
ON em.`employee_id` = e.`manager_id`
WHERE e.`manager_id` IN (3,7)
ORDER BY `first_name`;

#9-2
select 
	`e`.`employee_id`,
	`e`.`first_name`,
	`e`.`manager_id`,
	(
		select 
			`first_name`
		from `employees` as `em`
		where `e`.`manager_id` = `em`.`employee_id`
	) as `manager_name`
from `employees` as `e`
where `e`.`manager_id` in (3,7)
order by `e`.`first_name` asc;



#10-1

SELECT
	e.`employee_id`,
    CONCAT_WS(" ", e.`first_name`, e.`last_name`) AS `employee_name`,
    CONCAT_WS(" ", em.`first_name`, em.`last_name`) AS `manager_name`,
    d.`name` AS department_name
FROM `employees` AS e
JOIN `departments` AS d
ON e.`department_id` = d.`department_id`
JOIN `employees` AS em
ON e.`manager_id` = em.`employee_id`
ORDER BY `employee_id`
LIMIT 5;

#10-2
select 
	`e`.`employee_id`,
	concat_ws(' ', `e`.`first_name`, `e`.`last_name`) as `employee_name`,
	(
		select 
			concat_ws(' ', `em`.`first_name`, `em`.`last_name`) 
		from employees as `em`
		where `e`.`manager_id` = `em`.`employee_id` 
	) as `manager_name`,
	(
		select `name`
		from `departments` as `d`
		where `e`.`department_id` = `d`.`department_id`
	) as `department_name`
from `employees` as `e`
where `e`.`manager_id` is not null
order by `employee_id`
limit 5;

#11-1
SELECT AVG(`salary`) AS "min_average_salary"
FROM `employees`
GROUP BY `department_id`
ORDER BY `min_average_salary`
LIMIT 1;

#11-2
select min(`min_salary`)
from (
	select avg(`salary`) as `min_salary`
	from `employees` as `e`
	group by e.`department_id`
) as `min_department_salaries`;

USE `geography`;
#12
SELECT 
	c.`country_code`,
    m.`mountain_range`,
    p.`peak_name`,
    p.`elevation`
FROM `countries` AS c
JOIN `mountains_countries` AS mc
ON c.`country_code` = mc.`country_code`
JOIN `mountains` AS m
ON mc.`mountain_id` = m.`id`
JOIN `peaks` AS p
ON p.`mountain_id` = m.`id`
WHERE c.`country_code` = "BG" AND p.`elevation` > 2835
ORDER BY p.`elevation` DESC;



#13
SELECT 
	mc.`country_code`,
	COUNT(`mountain_range`) AS "mountain_range"
FROM `mountains` AS m
JOIN `mountains_countries` AS mc
ON mc.`mountain_id` = m.`id`
WHERE mc.`country_code` IN ("BG", "RU", "US")
GROUP BY `country_code`
ORDER BY `mountain_range` DESC;




#14
SELECT 
	c.`country_name`,
    r.`river_name`
FROM `countries` AS c
LEFT JOIN `countries_rivers` AS cr
ON c.`country_code` = cr.`country_code`
LEFT JOIN `rivers` AS r
ON cr.`river_id` = r.`id`
JOIN `continents` AS con
ON con.`continent_code` = c.`continent_code`
WHERE con.`continent_name` = "Africa"
ORDER BY `country_name` ASC
LIMIT 5;




#15-1 count of most used currency on the continent, filter currency in on country only
SELECT 
	c.`continent_code`,
    c.`currency_code`,
    COUNT(*) AS "currency_usage"
FROM `countries` AS c
JOIN `continents` AS con ON c.`continent_code`= con.`continent_code`
JOIN `currencies` AS cur ON c.`currency_code` = cur.`currency_code`
GROUP BY `continent_code`, `currency_code`
HAVING `currency_usage` = (
		SELECT COUNT(c_max.`currency_code`) AS "count"
        FROM `countries` AS c_max
        WHERE c_max.`continent_code` = c.`continent_code`
        GROUP BY c_max.`currency_code`
		ORDER BY `count` DESC
        LIMIT 1) 
	AND `currency_usage` > 1
ORDER BY `continent_code`, `currency_code`;

#15-2

select 
	cou.`continent_code`,
	cou.`currency_code`,
	count(`currency_code`) as `currency_usage`
from `countries` as `cou`
group by `continent_code`, `currency_code`
having `currency_usage` = 
	(
		select count(*) as `count`
		from `countries` as `cou2`
		where cou2.`continent_code` = cou.`continent_code`
		group by cou2.`continent_code`, cou2.`currency_code`
		order by `count` desc
		limit 1
	)
	and `currency_usage` > 1
order by cou.`continent_code`, `currency_usage` desc;

#16
SELECT COUNT(c.`country_code`)
FROM `countries` AS c
LEFT JOIN `mountains_countries` AS mc
ON mc.`country_code` = c.`country_code`
WHERE mc.`mountain_id` IS NULL;



#17
SELECT 
	`country_name`,
    MAX(p.`elevation`) AS `highest_peak_elevation`,
    MAX(r.`length`) AS `longest_river_lenght`
FROM `countries` AS c
LEFT JOIN `mountains_countries` AS mc
ON c.`country_code` = mc.`country_code`
LEFT JOIN `peaks` AS p
ON p.`mountain_id` = mc.`mountain_id`
LEFT JOIN `countries_rivers` AS cr
ON cr.`country_code` = c.`country_code`
LEFT JOIN `rivers` AS r
ON r.`id` = cr.`river_id`
GROUP BY `country_name`
ORDER BY p.`elevation` DESC, r.`length` DESC, `country_name`
LIMIT 5;
