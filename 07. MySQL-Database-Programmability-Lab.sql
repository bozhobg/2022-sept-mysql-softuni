#1-1
DELIMITER $$

CREATE FUNCTION ufn_count_employees_by_town(town_name VARCHAR(50))
RETURNS INT 
DETERMINISTIC
BEGIN    
    DECLARE id_for_town INT;
    DECLARE count_by_town INT;
    
    SET id_for_town := (
			SELECT `town_id` FROM `towns` 
			WHERE `name` = town_name
	);
            
	
    SET count_by_town := (
		SELECT COUNT(*) FROM `employees` AS `e`
        WHERE `e`.`address_id` IN (
			SELECT `address_id` FROM `addresses`
            WHERE `town_id` = id_for_town
		)
	);
    
    RETURN count_by_town;
END$$

DELIMITER ;


#1-2
delimiter $$

create function ufn_count_employees_by_town(town_name varchar(50))
returns int
deterministic 
begin
	declare `e_count` int;
    set `e_count` := (
		select count(*)
        from `employees` as `e`
        join `addresses` as `a`
        on e.`address_id` = a.`address_id`
        join `towns` as `t`
        on t.`town_id` = a.`town_id`
        where t.`name` = `town_name`
    );
	return `e_count`;
end
$$

delimiter ;

#2
DELIMITER $$

CREATE PROCEDURE usp_raise_salaries(department_name VARCHAR(50))
BEGIN
	
    UPDATE `employees` SET `salary` = `salary` * 1.05
    WHERE `department_id` = (
		SELECT `department_id` FROM `departments`
		WHERE `name` = department_name);
    
END$$

DELIMITER ;

#3
DELIMITER $$

CREATE PROCEDURE usp_raise_salary_by_id(id INT)
BEGIN
	DECLARE count_by_id INT;  
    
    START TRANSACTION;
    
    SET count_by_id := (
    SELECT COUNT(*) FROM `employees` WHERE `employee_id` = id
    );
    
    UPDATE `employees` SET `salary` = `salary` * 1.05 
    WHERE `employee_id` = id;

	IF (count_by_id < 1) THEN 
		ROLLBACK;
    ELSE 
		COMMIT;
	END IF;
    
END
$$

DELIMITER ;

#4
CREATE TABLE `deleted_employees`(
  `employee_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `middle_name` varchar(50) DEFAULT NULL,
  `job_title` varchar(50) NOT NULL,
  `salary` decimal(19,4) NOT NULL,
  PRIMARY KEY (`employee_id`)
);

DELIMITER $$

CREATE TRIGGER tr_deleted_employees
AFTER DELETE 
ON `towns`
FOR EACH ROW 
BEGIN
	INSERT INTO `deleted_employees` VALUES(
		OLD.`employee_id`, 
		OLD.`first_name`, 
        OLD.`last_name`, 
        OLD.`middle_name`,
		OLD.`job_title`, 
        OLD.`salary`);
END
$$

DELIMITER ;

