#1
SELECT COUNT(*) AS "count"
FROM `wizzard_deposits`;

#2
SELECT MAX(`magic_wand_size`) AS "Longest Magic Wand"
FROM `wizzard_deposits`;

#2.1 Second longest OFFSET
SELECT DISTINCT `magic_wand_size` AS "Longest Magic Wand"
FROM `wizzard_deposits`
ORDER BY `magic_wand_size` DESC
LIMIT 1 OFFSET 1;

#3
SELECT 
	`deposit_group`,
	MAX(`magic_wand_size`) AS "longest_magic_wand"
FROM `wizzard_deposits`
GROUP BY `deposit_group`
ORDER BY `longest_magic_wand`, `deposit_group`;

#4-1
SELECT `deposit_group`
FROM `wizzard_deposits`
GROUP BY(`deposit_group`)
ORDER BY AVG(`magic_wand_size`)
LIMIT 1;

#4-2 using derived table
select `deposit_group`
from (
	select `deposit_group`, avg(`magic_wand_size`) as `avg_size`
    from `wizzard_deposits`
    group by `deposit_group`
    order by `avg_size` asc
	limit 1
) as `group_min_avg_wand_size`;

#5
SELECT 
	`deposit_group`,
    SUM(`deposit_amount`) AS "total_sum"
FROM `wizzard_deposits`
GROUP BY `deposit_group`
ORDER BY `total_sum`;

#6
SELECT
	`deposit_group`,
    SUM(`deposit_amount`) AS "total_sum"
FROM `wizzard_deposits`
WHERE `magic_wand_creator` = "Ollivander family"
GROUP BY `deposit_group`
ORDER BY `deposit_group`;

#7
SELECT 
		`deposit_group`,
		SUM(`deposit_amount`) AS "total_sum"
FROM `wizzard_deposits`
WHERE `magic_wand_creator` = "Ollivander family"
GROUP BY `deposit_group`
HAVING `total_sum` < 150000
ORDER BY `total_sum` DESC;

#8
SELECT 
	`deposit_group`,
    `magic_wand_creator`,
    MIN(`deposit_charge`) AS "min_deposit_charge"
FROM `wizzard_deposits`
GROUP BY `deposit_group`,`magic_wand_creator`
ORDER BY `magic_wand_creator`, `deposit_group`;

#9
SELECT 
	(
    CASE 
    WHEN `age` BETWEEN 0 AND 10 THEN "[0-10]"
    WHEN `age` BETWEEN 11 AND 20 THEN "[11-20]"
    WHEN `age` BETWEEN 21 AND 30 THEN "[21-30]"
    WHEN `age` BETWEEN 31 AND 40 THEN "[31-40]"
    WHEN `age` BETWEEN 41 AND 50 THEN "[41-50]"
    WHEN `age` BETWEEN 51 AND 60 THEN "[51-60]"
    ELSE "[61+]"
#	WHEN `age` >= 61 THEN "[60+]" (-10 case)
    END
    ) AS "age_group",
    COUNT(*) AS "wizzard_count"
FROM `wizzard_deposits`
GROUP BY `age_group`
ORDER BY `age_group`;

#10
SELECT LEFT(`first_name`, 1) AS "first_letter"
FROM `wizzard_deposits`
WHERE `deposit_group` = "Troll Chest"
GROUP BY `first_letter`
ORDER BY `first_letter`;

#11
SELECT 
	`deposit_group`,
    `is_deposit_expired`,
    AVG(`deposit_interest`) AS "Average Interest"
FROM `wizzard_deposits`
WHERE `deposit_start_date` > "1985-01-01"
GROUP BY `deposit_group`, `is_deposit_expired`
ORDER BY `deposit_group` DESC;

#12
USE `soft_uni`;

SELECT 
	`department_id`,
    MIN(`salary`) AS "minimum_salary"
FROM `employees`
WHERE `department_id` IN (2, 5, 7) AND `hire_date` > "2000-01-01"
GROUP BY `department_id`
ORDER BY `department_id`;

#13
--Work flow changing foreign key on delete behavior to on delete set null --
show databases;
show tables from `information_schema`;
describe `information_schema`.`key_column_usage`;

select `column_name`, `constraint_name`, `referenced_table_name`, `referenced_column_name`
from `information_schema`.`key_column_usage`
where 
	`table_schema` = 'soft_uni'
    and `table_name` = 'employees'
    and `column_name` = 'manager_id';
    
select database();
select user();

show tables;
describe `employees`;

alter table `employees`
drop constraint `fk_employees_employees`;

alter table `employees`
add constraint fk_employees_employees
foreign key `employees`(`manager_id`) 
references `employees`(`employee_id`)
on delete set null;
-- end of fk change --

#following script should work
select *
from `employees`
where 
	`salary` > 30000 
	and `manager_id` = 42;
    
delete from `employees`
where 
	`salary` > 30000 
	and `manager_id` = 42;

update `employees`
set `salary` = `salary` + 5000
where `salary` > 30000 and `department_id` = 1;

select `department_id`, avg(`salary`)
from `employees` 
group by `department_id`
order by `department_id`;


#14
SELECT 
	`department_id`,
    MAX(`salary`) AS "max_salary"
FROM `employees`
GROUP BY `department_id`
HAVING `max_salary` NOT BETWEEN 30000 AND 70000
ORDER BY `department_id`;

#15
SELECT COUNT(*)
FROM `employees`
WHERE `manager_id` IS NULL;

#16
SELECT
	`department_id`,
	(
    SELECT DISTINCT `salary`
    FROM `employees` e2
    WHERE `e2`.`department_id` = `e1`.`department_id`
    ORDER BY `salary` DESC
    LIMIT 1 OFFSET 2
    ) AS "third_highest_salary"
FROM `employees` e1
GROUP BY `department_id`
HAVING `third_highest_salary` IS NOT NULL
ORDER BY `department_id`;

#17
select 
	`first_name`, 
	`last_name`, 
	`department_id` as `di`
from `employees` as `e1`
where `e1`.`salary` > 
	(
		select avg(`salary`)
		from `employees` as `e2`
		where `salary` is not null and `e2`.`department_id` = `e1`.`department_id`
		group by `department_id`
	)
order by `department_id`, `employee_id`
limit 10;

#18
SELECT 
	`department_id`,
    SUM(`salary`) AS "total_salary"
FROM `employees`
GROUP BY `department_id`
ORDER BY `department_id`;

