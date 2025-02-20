#0

CREATE DATABASE `minions`;

USE `minions`;

#1

CREATE TABLE `minions` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50),
    `age` INT
);

CREATE TABLE `towns` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50)
);

#2

ALTER TABLE `minions`
ADD COLUMN `town_id` INT NOT NULL,
ADD CONSTRAINT `fk_minions_towns`
FOREIGN KEY (`town_id`)
REFERENCES `towns`(`id`);

#3

INSERT INTO `towns`(`id`,`name`)
VALUES 
(1, "Sofia"),
(2, "Plovdiv"),
(3, "Varna");

INSERT INTO `minions` (`id`,`name`,`age`,`town_id`)
VALUES 
(1,"Kevin", 22, 1),
(2,"Bob", 15, 3),
(3,"Steward", NULL, 2);

#4

TRUNCATE TABLE `minions`;

#5

DROP TABLE `minions`;
DROP TABLE `towns`;

#6

CREATE TABLE `people` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(200) NOT NULL,
`picture` BLOB(2000000),
`height` DECIMAL(10,2),
`weight` DECIMAL(10,2),
`gender` ENUM("m","f") NOT NULL,
`birthdate` DATE NOT NULL,
`biography` TEXT
);

INSERT INTO `people`(`name`, `gender`, `birthdate`)
VALUES
("dragan", "f", DATE(NOW())),
("IVAN", "m", DATE(NOW())),
("Elitsa", "f", DATE(NOW())),
("Dilyana", "f", DATE(NOW())),
("Shishman", "m", DATE(NOW()));

#7

CREATE TABLE `users`(
`id` INT AUTO_INCREMENT PRIMARY KEY,
`username` VARCHAR(30) UNIQUE,
`password` VARCHAR(26) NOT NULL,
`profile_picture` BLOB(900000),
`last_login_time` DATETIME,
`is_deleted` BOOLEAN
);

INSERT INTO `users` (`username`, `password`)
VALUES 
("Dragan", "dRAGAN133"),
("Canko", "naDraganBratMu"),
("111", "!!!"),
("sheise", "shit on it"),
("lastUserOnEarth", "firstBackwords");

INSERT INTO `users`(`username`, `password`)
VALUES
("Dragan", "dragiMoy");

#8

USE `minions`;

ALTER TABLE `users`
DROP PRIMARY KEY,
ADD PRIMARY KEY pk_users (`id`, `username`);

#9
USE `minions`;

ALTER TABLE `users`
MODIFY COLUMN `last_login_time` DATETIME DEFAULT NOW();

#10

ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT `pk_users`
PRIMARY KEY `users`(`id`);

ALTER TABLE `users`
MODIFY COLUMN `username` VARCHAR(30) UNIQUE;

#11

CREATE DATABASE `movies`;

USE `movies`;

CREATE TABLE `directors`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`director_name` VARCHAR(50) NOT NULL,
`notes` TEXT
);

INSERT INTO `directors`(`director_name`, `notes`)
VALUES
("Steven Sp", "Genious"),
("test_dir2", NULL),
("test_dir3", "notes3"),
("test_dir4", NULL),
("test_dir5", "notes5");

#so far done

CREATE TABLE `genres` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`genre_name` VARCHAR(20) NOT NULL,
`notes` TEXT
);

INSERT INTO `genres`(`genre_name`, `notes`)
VALUES
("horror", "dont watch if you scare easily"),
("", NULL),
("comedy", "for the laughs"),
("action", "action packed"),
("adventure", NULL);

#so far done

CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`category_name` VARCHAR(20) NOT NULL,
`notes` TEXT
);

INSERT INTO `categories`(`category_name`, `notes`)
VALUES
("cat1", NULL),
("cat2", NULL),
("cat3", NULL),
("cat4", "notes4"),
("cat5", NULL);

#so far done

CREATE TABLE `movies`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`title` VARCHAR(40) NOT NULL,
`director_id`INT ,
`copyright_year` YEAR,
`length` DECIMAL(2,1),
`genre_id` INT,
`category_id` INT,
`rating` DECIMAL(3,2),
`notes` TEXT
);

INSERT INTO `movies`
(`title`,`director_id`,`copyright_year`, `length`, 
`genre_id`, `category_id`, `rating`, `notes`)
 VALUES
 ("Terminator" ,1 , 1982, 2.5,
 4, 5, 9.98,"djigi with it1"),
 ("Terminator 2" ,1 , 1987, 2.5,
 4, 5, 9.99,"djigi with it again"),
 ("Sphere " ,1 , 1996, 3,
 4, 5, 8,"djigi with it3"),
 ("Titanic" ,5 , 1996, 2.5,
 2, 3, 1.01,"ugh"),
 ("Titanic 3" ,5 , 2030, 3,
 2, 3, 2.00,"ugh");
 
 #12
 
 CREATE DATABASE `car_rental`;
 
 USE `car_rental`;
 
 CREATE TABLE `categories`(
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`category` VARCHAR(30) NOT NULL, 
`daily_rate` DOUBLE DEFAULT 5, 
`weekly_rate` DOUBLE, 
`monthly_rate` DOUBLE, 
`weekend_rate` DOUBLE DEFAULT 10
 );
 
 INSERT INTO `categories`(`category`)
 VALUES
 ("roadster"),
 ("tracktor"),
 ("van");
 
 CREATE TABLE `cars`(
 `id` INT PRIMARY KEY AUTO_INCREMENT, 
 `plate_number` CHAR(7) UNIQUE, #NOT NULL?#
 `make` VARCHAR(10), 
 `model` VARCHAR(15), 
 `car_year` YEAR, 
 `category_id` INT, 
 `doors` INT(1), 
 `picture` BLOB(2000000), 
 `car_condition` TEXT, 
 `available` BOOLEAN NOT NULL DEFAULT FALSE
 );
 
 INSERT INTO `cars`
 (`plate_number`, `make`, `car_year`, `category_id`,`doors`)
 VALUES
 ("9999", "BMW", 1999, 1, 0),
 ("Blade", "Toyota", 2100, 2, 0),
 ("1313", "Tesla", 1990, 3, 0);
 
 CREATE TABLE `employees`(
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `first_name` VARCHAR(10) NOT NULL,
 `last_name` VARCHAR(10) NOT NULL, 
 `title` ENUM("Mr", "Mrs", "Ms"), 
 `notes` TEXT
 );
 
 INSERT INTO `employees`(`first_name`,`last_name`,`title`)
 VALUES
 ("Bozho", "Bozhov","Mr"),
 ("Dragan","Draganov","Mrs"),
 ("x","x","Ms");
 
 CREATE TABLE `customers`(
 `id` INT PRIMARY KEY AUTO_INCREMENT, 
 `driver_licence_number` INT(10) UNIQUE NOT NULL, 
 `full_name` VARCHAR(20) NOT NULL, 
 `address` VARCHAR(50), 
 `city` VARCHAR(10) DEFAULT "Varna", 
 `zip_code` INT(10) DEFAULT 9000, 
 `notes` TEXT
 );
 
INSERT INTO `customers`(`driver_licence_number`, `full_name`)
 VALUES
 (1111111111, "Numero Uno"),
 (1111111112, "Next 2"),
 (1111111113, "Next 3");
 
 CREATE TABLE `rental_orders`(
 `id` INT PRIMARY KEY AUTO_INCREMENT, 
 `employee_id` INT NOT NULL, 
 `customer_id` INT NOT NULL, 
 `car_id` INT, 
 `car_condition` TEXT, 
 `tank_level` DOUBLE(3,3), 
 `kilometrage_start` INT, 
 `kilometrage_end` INT, 
 `total_kilometrage` INT, 
 `start_date` DATE, 
 `end_date` DATE, 
 `total_days` INT, 
 `rate_applied` DOUBLE, 
 `tax_rate` DOUBLE, 
 `order_status` VARCHAR(20), 
 `notes` TEXT
 );
 
 INSERT INTO `rental_orders`(`employee_id`, `customer_id`)
 VALUES 
 (1,1),
 (2,1),
 (3,2);


 
 #13-1
 
 CREATE DATABASE `soft_uni`;
 
 USE `soft_uni`;
 
 
CREATE TABLE `towns`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL
);

INSERT INTO `towns`(`name`)
VALUES ("Sofia"), ("Plovdiv"), ("Varna"), ("Burgas");

CREATE TABLE `addresses`(
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`address_text`VARCHAR(100) NOT NULL,
`town_id` INT NOT NULL
);

CREATE TABLE `departments`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30) NOT NULL
);

INSERT INTO `departments`(`name`)
VALUES 
("Engineering"),
("Sales"), 
("Marketing"), 
("Software Development"), 
("Quality Assurance");

CREATE TABLE `employees`(
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`first_name` VARCHAR(50) NOT NULL, 
`middle_name` VARCHAR(50) NOT NULL, 
`last_name` VARCHAR(50) NOT NULL, 
`job_title` VARCHAR(30) NOT NULL, 
`department_id` INT NOT NULL, 
`hire_date` DATE NOT NULL, 
`salary` DOUBLE NOT NULL, 
`address_id` INT
);

INSERT INTO `employees`(`first_name`, `middle_name`, `last_name`, 
`job_title`, `department_id`, `hire_date`, `salary`)
VALUES 
("Ivan", "Ivanov", "Ivanov", ".NET Developer", 4, "2013-02-01", 3500.00),
("Petar", "Petrov", "Petrov", "Senior Engineer", 1, "2004-03-02", 4000.00),
("Maria", "Petrova", "Ivanova", "Intern", 5, "2016-08-28", 525.25),
("Georgi", "Terziev", "Ivanov", "CEO", 2, "2007-12-09", 3000.00),
("Peter", "Pan", "Pan", "Intern", 3, "2016-08-28", 599.88);

ALTER TABLE `employees`
ADD CONSTRAINT `fk_employees_departments`
FOREIGN KEY (`department_id`)
REFERENCES `departments`(`id`);

ALTER TABLE `addresses`
ADD CONSTRAINT `fk_addresses_towns`
FOREIGN KEY (`town_id`)
REFERENCES `towns`(`id`);

#13-2 (revision)


CREATE TABLE `addresses`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`address_text` VARCHAR(255) NOT NULL,
`town_id` INT,
CONSTRAINT `fk_towns` 
FOREIGN KEY (`town_id`) REFERENCES `towns`(`id`)
);

CREATE TABLE `departments`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE `employees`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(50),
`middle_name` VARCHAR(50),
`last_name` VARCHAR(50),
`job_title` VARCHAR(50),
`department_id` INT,
CONSTRAINT `fk_departments` 
FOREIGN KEY (`department_id`) 
REFERENCES `departments`(`id`),
`hire_date` DATE,
`salary` DECIMAL(10,2),
`address_id` INT,
CONSTRAINT `fk_addresses`
FOREIGN KEY (`address_id`) 
REFERENCES `addresses`(`id`)
);

INSERT INTO `towns`(`name`)
VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas');

INSERT INTO `departments`(`name`)
VALUES ('Engineering'), 
('Sales'), 
('Marketing'), 
('Software Development'), 
('Quality Assurance');

INSERT INTO `employees`
(
`first_name`, 
`middle_name`, 
`last_name`, 
`job_title`, 
`department_id`, 
`hire_date`, 
`salary`
)
VALUES
(
SUBSTRING_INDEX('Ivan Ivanov Ivanov', ' ', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX('Ivan Ivanov Ivanov', ' ', 2), ' ', -1),
SUBSTRING_INDEX('Ivan Ivanov Ivanov', ' ', -1),
'.NET Developer',
(
SELECT `id` 
FROM `departments` AS `d`
WHERE `d`.`name` LIKE 'Software Development' 
LIMIT 1
),
STR_TO_DATE('01/02/2013', '%d/%m/%Y'),
3500.00
),
(
SUBSTRING_INDEX('Petar Petrov Petrov', ' ', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX('Petar Petrov Petrov', ' ', 2), ' ', -1),
SUBSTRING_INDEX('Petar Petrov Petrov', ' ', -1),
'Senior Engineer',
(
SELECT `id`
FROM `departments` AS `d`
WHERE `d`.`name` LIKE 'Engineering'
),
STR_TO_DATE('02/03/2004', '%d/%m/%Y'),
4000.00
),
(
SUBSTRING_INDEX('Maria Petrova Ivanova', ' ', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX('Maria Petrova Ivanova', ' ', 2), ' ', -1),
SUBSTRING_INDEX('Maria Petrova Ivanova', ' ', -1),
'Intern',
(
SELECT `id`
FROM `departments` AS `d`
WHERE `d`.`name` LIKE 'Quality Assurance'
),
STR_TO_DATE('28/08/2016', '%d/%m/%Y'),
525.25
),
(
SUBSTRING_INDEX('Georgi Terziev Ivanov', ' ', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX('Georgi Terziev Ivanov', ' ', 2), ' ', -1),
SUBSTRING_INDEX('Georgi Terziev Ivanov', ' ', -1),
'CEO',
(
SELECT `id`
FROM `departments` AS `d`
WHERE `d`.`name` LIKE 'Sales'
),
STR_TO_DATE('09/12/2007', '%d/%m/%Y'),
3000.00
),
(
SUBSTRING_INDEX('Peter Pan Pan', ' ', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX('Peter Pan Pan', ' ', 2), ' ', -1),
SUBSTRING_INDEX('Peter Pan Pan', ' ', -1),
'Intern',
(
SELECT `id`
FROM `departments` AS `d`
WHERE `d`.`name` LIKE 'Marketing'
),
STR_TO_DATE('28/08/2016', '%d/%m/%Y'),
599.88
);

#14

SELECT * FROM `towns`;
SELECT * FROM `departments`;
SELECT * FROM `employees`;

#15

SELECT * FROM `towns`
ORDER BY `name`;

SELECT * FROM `departments`
ORDER BY `name`;

SELECT * FROM `employees`
ORDER BY `salary` DESC;

#16

SELECT `name` FROM `towns`
ORDER BY `name`;

SELECT `name` FROM `departments`
ORDER BY `name`;

SELECT `first_name`, `last_name`, `job_title`, `salary` FROM `employees`
ORDER BY `salary` DESC;

#17

UPDATE `employees`
SET `salary` = `salary` * 1.1;
SELECT `salary` FROM `employees`;
