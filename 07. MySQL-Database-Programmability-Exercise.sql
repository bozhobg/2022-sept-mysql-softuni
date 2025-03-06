#1

DELIMITER $$

CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN

	SELECT `first_name`, `last_name`
    FROM `employees`
    WHERE `salary` > 35000
    ORDER BY `first_name`, `last_name`, `employee_id`;

END$$

DELIMITER ;

#2
DELIMITER $$

CREATE PROCEDURE usp_get_employees_salary_above(lower_boundary DECIMAL(19, 4))
BEGIN

	SELECT `first_name`, `last_name`
    FROM `employees`
    WHERE `salary` >= lower_boundary
    ORDER BY `first_name`, `last_name`, `employee_id`;

END$$

DELIMITER ;

#3
DELIMITER $$

CREATE PROCEDURE usp_get_towns_starting_with(name_beginning VARCHAR(50))
BEGIN
	SELECT `name` AS `town_name` FROM `towns`
    WHERE `name` LIKE CONCAT(name_beginning, "%")
    #WHERE LEFT (`name`, LENGTH(`name_beginning`)) = `name_beginning`
    ORDER BY `name`;
END$$

DELIMITER ;

#4
DELIMITER $$

CREATE PROCEDURE usp_get_employees_from_town(town_name VARCHAR(50))
BEGIN
	SELECT `first_name`, `last_name` 
    FROM `employees` AS e
    JOIN `addresses` AS a 
    ON e.`address_id` = a.`address_id` #USING (`address_id`)
    JOIN `towns` AS t 
    ON t.`town_id` = a.`town_id`
    WHERE t.`name` = town_name #USING (`town_id`)
    ORDER BY e.`first_name`, e.`last_name`, e.`employee_id`;
END
$$

DELIMITER ;

#5-1
DELIMITER $$

CREATE FUNCTION ufn_get_salary_level(salary DECIMAL(19,4))
RETURNS VARCHAR(10)
DETERMINISTIC 
BEGIN
	DECLARE salary_level VARCHAR(10);
    
    IF salary <  30000 THEN SET salary_level := "Low";
    ELSEIF salary <= 50000 THEN SET salary_level := "Average";
    ELSE SET salary_level := "High";
    END IF;
	RETURN salary_level;
END
$$

DELIMITER ;

#5-2
DELIMITER $$

create function `ufn_get_salary_level`(`input_salary` decimal(19,4))
returns varchar(50)
deterministic
begin
	declare `result` varchar(10);
	set `result` = (case
		when `input_salary` < 30000 
        then  'Low'
        when (`input_salary` between 30000 and 50000) 
        then 'Average'
        else 'High'
    end);
    return `result`;
end
$$

DELIMITER ;

#6-2
DELIMITER $$

CREATE PROCEDURE usp_get_employees_by_salary_level(salary_level VARCHAR(10))
BEGIN 
	SELECT `first_name`, `last_name` FROM `employees`
    WHERE ufn_get_salary_level(`salary`) = salary_level
    ORDER BY `first_name` DESC, `last_name` DESC;
END$$

DELIMITER ;

#6-2

delimiter $$

create procedure `usp_get_employees_by_salary_level`(`salary_level` varchar(50))
begin
	select `first_name`, `last_name`
	from `employees`
	where (case 
			when `salary_level` = 'Low' then `salary` < 30000
			when `salary_level` = 'Average' then (`salary` between 30000 and 50000)
			when `salary_level` = 'High' then `salary` > 50000
		end)
	order by `first_name` desc, `last_name` desc;  
end
$$

delimiter ;

#7
DELIMITER $$

CREATE FUNCTION ufn_is_word_comprised(set_of_letters VARCHAR(50), word VARCHAR(50))
RETURNS INT #0 -> false, 1 -> true
DETERMINISTIC
BEGIN
	RETURN word REGEXP (CONCAT("^[", set_of_letters, "]+$"));
END$$

DELIMITER ;

#8
DELIMITER $$

CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
	SELECT CONCAT_WS(" ", `first_name`, `last_name`) AS "full_name"
    FROM `account_holders`
    ORDER BY `full_name`, `id`;
END
$$

DELIMITER ;

#9
DELIMITER $$

CREATE PROCEDURE usp_get_holders_with_balance_higher_than(money DECIMAL(19, 4))
BEGIN
	SELECT ah.`first_name`, ah.`last_name`
    FROM `account_holders` AS ah
    LEFT JOIN `accounts` AS a
    ON ah.`id`= a.`account_holder_id`
    GROUP BY ah.`id`
    HAVING SUM(a.`balance`) > money
    ORDER BY ah.`id`;
END
$$

DELIMITER ;

#10
DELIMITER $$

CREATE FUNCTION ufn_calculate_future_value(sum DECIMAL(19,4), yearly_interest DOUBLE, years INT)
RETURNS DECIMAL(19, 4)
DETERMINISTIC
BEGIN
	DECLARE future_value DECIMAL(19, 4);
    
    SET future_value := sum * POW((1 + yearly_interest), years);
    
    RETURN future_value;
END
$$

DELIMITER ;

#11
DELIMITER $$

CREATE PROCEDURE usp_calculate_future_value_for_account(acc_id INT, interest_rate DECIMAL(19, 4))
BEGIN 
    
    SELECT 
		a.`id` AS "account_id", 
		ah.`first_name`, 
        ah.`last_name`, 
        a.`balance` AS  "current_balance",
        ufn_calculate_future_value(a.`balance`, interest_rate, 5) AS "balance_in_5_years"
    FROM `account_holders` AS ah
    JOIN `accounts` AS a
    ON a.`account_holder_id` = ah.`id`
    WHERE a.`id` = acc_id;
		
END
$$

DELIMITER ;

#12
DELIMITER $$

CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(19, 4))
BEGIN
	START TRANSACTION;
		IF (money_amount <= 0) THEN ROLLBACK;
        ELSE 
			UPDATE `accounts` SET `balance` = `balance` + money_amount
            WHERE `id` = account_id;
    END IF;
END$$

DELIMITER ;

#13-1
DELIMITER $$

CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19, 4))
BEGIN
	START TRANSACTION;
    IF money_amount <= 0 
		OR (SELECT `balance` FROM `accounts` WHERE `id` = account_id) < money_amount  
		THEN ROLLBACK;
	ELSE 
		UPDATE `accounts` SET `balance` = `balance` - money_amount
		WHERE `id` = account_id;
        COMMIT;
	END IF;
END$$

DELIMITER ;

#13-2
delimiter $$

create procedure `usp_withdraw_money`(
	`account_id` int, 
    `money_amount` decimal(19,4)
)
begin
	declare `current_balance` decimal(19,4);
    set `current_balance` = (
		select `balance`
        from `accounts`
        where `id` = `account_id`
        limit 1
    );
    start transaction;
    
    update `accounts` 
    set `balance` = `balance` - `money_amount`
    where `id` = `account_id`;
    
    if `money_amount` <= 0 then rollback;
    elseif `money_amount` > `current_balance` then rollback;
    else commit;
    end if;
end
$$

delimiter ;

#14-1
DELIMITER $$
CREATE PROCEDURE usp_transfer_money(from_account_id INT, to_account_id INT, amount DECIMAL(19, 4))
BEGIN
	START TRANSACTION;
    IF 
		from_account_id = to_account_id OR
        amount <= 0 OR
        (SELECT `balance` FROM `accounts` WHERE `id` = from_account_id) < amount OR
        (SELECT COUNT(`id`) FROM `accounts` WHERE `id` = from_account_id) <> 1 OR
        (SELECT COUNT(`id`) FROM `accounts` WHERE `id` = to_account_id) <> 1
        THEN ROLLBACK;
    ELSE
		UPDATE `accounts` SET `balance` = `balance` - amount 
        WHERE `id` = from_account_id;
        UPDATE `accounts` SET `balance` = `balance` + amount
        WHERE `id` = to_account_id;
	END IF;
END$$

DELIMITER ;

#14-2
delimiter $$

create procedure `usp_transfer_money`(
	`from_account_id` int, 
    `to_account_id` int, 
    `amount` decimal(19,4)
)
begin
	declare `from_balance` decimal(19,4);
    
    set `from_balance` = (
		select `balance` from `accounts`  as `a`
		where a.`id` = `from_account_id` 
		limit 1
		);
        
	start transaction;
    
    update `accounts`
    set `balance` = `balance` + `amount`
    where `id` = `to_account_id`;
    
    update `accounts`
    set `balance` = `balance` - `amount`
    where `id` = `from_account_id`;
    
    if (`from_account_id` not in (select `id` from `accounts`)) 
		then rollback;
	elseif (`to_account_id` not in (select `id` from `accounts`)) 
		then rollback;
	elseif (`amount` <= 0) 
		then rollback;
	elseif (`from_balance` - `amount` < 0) 
		then rollback; #this is problematic!
	elseif (`from_account_id` = `to_account_id`)
		then rollback;
	else commit;
    end if;
    
end
$$

delimiter ;

#15

CREATE TABLE `logs`(
	`log_id` INT PRIMARY KEY AUTO_INCREMENT,
    `account_id` INT NOT NULL,
    `old_sum` DECIMAL(19, 4) NOT NULL,
    `new_sum` DECIMAL(19, 4) NOT NULL
);

DELIMITER $$
CREATE TRIGGER tr_change_balance_account
AFTER UPDATE ON `accounts`
FOR EACH ROW
BEGIN 
	INSERT INTO `logs`(`account_id`, `old_sum`, `new_sum`)
    VALUES(OLD.`id`, OLD.`balance`, NEW.`balance`);
END$$



#16-1 plus all from problem 15 (without use of 'delimiter $$')

CREATE TABLE `notification_emails`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `recipient` INT NOT NULL,
    `subject` TEXT,
    `body` TEXT
);

DELIMITER $$

CREATE TRIGGER tr_log_insert_notification_entry
AFTER INSERT ON `logs`
FOR EACH ROW
BEGIN 
	INSERT INTO `notification_emails`(`recipient`, `subject`, `body`)
    VALUES(
		NEW.`account_id`, 
		CONCAT("Balance chage for account: ", NEW.`account_id`),
        CONCAT_WS("On", NOW(), "your balance was changet from", NEW.`old_sum`, "to", NEW.`new_sum`,".")
        );
END$$

DELIMITER ;

#16-2 plus all from problem 15 (without use of 'delimiter $$')

create table `notification_emails`(
	`id` int primary key auto_increment,
    `recipient` int not null,
    `subject` varchar(50),
    `body` varchar(255)
);

delimiter $$

create trigger `tr_notification_emails`
after insert
on `logs`
for each row
begin
	insert into `notification_emails`(
		`recipient`,
		`subject`,
		`body`
    ) values (
		new.`account_id`,
        concat("Balance change for account: ", new.`account_id`),
        concat(
			"On ", 
            #"Sep 15 2016 at 11:44:06 AM", 
            date_format(now(), "%b %e %Y at %r"),
			" your balance was changed from ", 
			new.`old_sum`, 
            " to ", 
            new.`new_sum`,
            "."
            )
    );
end
$$

delimiter ;
