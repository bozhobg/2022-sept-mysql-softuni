create database `test_relations`;

use `test_relations`;

#1
create table `passports`(
	`passport_id` int primary key auto_increment,
    `passport_number` varchar(50) unique
);

insert into `passports`(`passport_id`, `passport_number`) 
values 
	(101, "N34FG21B"),
    (102, "K65LO4R7"),
    (103, "ZE657QP2");
 
 
 create table `people`(
	`person_id` int primary key auto_increment,
    `first_name` varchar(50),
    `salary` decimal(9, 2),
    `passport_id` int unique,
    constraint `fk_people_passports`
    foreign key (`passport_id`)
    references `passports`(`passport_id`)
);
 
 INSERT INTO `people` (`person_id`, `first_name`, `salary`, `passport_id`)
 VALUES 
	(1, "Roberto", 43300.00, 102),
    (2, "Tom",  56100.00, 103),
    (3, "Yana", 60200.00, 101);
    
    
    
#2
CREATE TABLE `manufacturers` (
    `manufacturer_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `established_on` DATE
);
    
    INSERT INTO `manufacturers`(`name`, `established_on`)
    VALUES
		("BMW", "1916-03-01"),
		("Tesla", "2003-01-01"),
		("Lada", "1916-05-01");

CREATE TABLE `models` (
    `model_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(70) NOT NULL,
    `manufacturer_id` INT,
    CONSTRAINT `fk_models_manufacturers` FOREIGN KEY (`manufacturer_id`)
        REFERENCES `manufacturers` (`manufacturer_id`)
);        

INSERT INTO `models`(`model_id`, `name`, `manufacturer_id`)
VALUES 
	(101, "X1", 1),
	(102, "i6", 1),
	(103, "Model S", 2),
	(104, "Model X", 2),
	(105, "Model 3", 2),
	(106, "Nova", 3);
    
    
    
#3

CREATE TABLE `students`(
	`student_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50)
);

INSERT INTO `students` (`name`)
VALUES 
	("Mila"),
    ("Toni"),
    ("Ron");
    
CREATE TABLE `exams` (
	`exam_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) 
);

ALTER TABLE `exams` AUTO_INCREMENT = 101;

INSERT INTO `exams`(`name`)
VALUES
	("Spring MVC"),
    ("Neo4j"),
    ("Oracle 11g");

CREATE TABLE `students_exams`(
	`student_id` INT NOT NULL,
    `exam_id` INT NOT NULL,
    
    CONSTRAINT `primary_keys`
    PRIMARY KEY (`student_id`, `exam_id`),
    
    CONSTRAINT `fk_students_exams_students`
    FOREIGN KEY (`student_id`)
    REFERENCES `students`(`student_id`),
    
    CONSTRAINT `fk_students_exams_exams`
    FOREIGN KEY (`exam_id`)
    REFERENCES `exams`(`exam_id`)
);

INSERT INTO `students_exams`(`student_id`, `exam_id`)
VALUES
	(1, 101),
	(1, 102),
	(2, 101),
	(3, 103),
	(2, 102),
	(2, 103);



#4-1

CREATE TABLE `teachers`(
	`teacher_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50),
    `manager_id` INT#,
    #CONSTRAINT `fk_manager_id_teacher_id`
    #FOREIGN KEY (`manager_id`)
    #REFERENCES `teachers`(`teacher_id`)
    );
    
ALTER TABLE `teachers`AUTO_INCREMENT = 101;
    
INSERT INTO `teachers`(`name`, `manager_id`)
VALUES 
	("John", NULL),
    ("Maya", 106),
    ("Silvia", 106),
    ("Ted", 105),
    ("Mark", 101),
    ("Greta", 101);
    
ALTER TABLE `teachers`
ADD CONSTRAINT `fk_manager_id_teacher_id`
FOREIGN KEY (`manager_id`)
REFERENCES `teachers`(`teacher_id`);
    
#4-2

create table `teachers`(
	`teacher_id` int primary key auto_increment,
	`name` varchar(50) not null,
	`manager_id` int,
	foreign key (`manager_id`)
	references `teachers`(`teacher_id`)
);

alter table `teachers` auto_increment = 101;

insert into `teachers`(`name`)
values 
	('John'),
	('Maya'),
	('Silvia'),
	('Ted'),
	('Mark'),
	('Greta');

update `teachers`
set `manager_id` = 106
where `teacher_id` in (102, 103);

update `teachers`
set `manager_id` = 105
where `teacher_id` in (104);

update `teachers`
set `manager_id` = 101
where `teacher_id` in (105, 106);

#5-1:
CREATE DATABASE `relations05`;

USE `relations05`;

CREATE TABLE `items`(
	`item_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50),
    `item_type_id` INT
);

 CREATE TABLE `item_types`(
	`item_type_id` INT PRIMARY KEY,
    `name` VARCHAR(50)
 );
 
 CREATE TABLE `customers`(
	`customer_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50),
    `birthday` DATE,
    `city_id` INT
 );

CREATE TABLE `orders`(
	`order_id` INT PRIMARY KEY AUTO_INCREMENT,
    `customer_id` INT
);

CREATE TABLE `cities` (
	`city_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50)
);

CREATE TABLE `order_items` (
	`order_id` INT NOT NULL,
    `item_id` INT NOT NULL
);

ALTER TABLE `items` 
ADD CONSTRAINT `fk_items_item_types`
FOREIGN KEY (`item_type_id`)
REFERENCES `item_types`(`item_type_id`);

ALTER TABLE `customers`
ADD CONSTRAINT `fk_customers_cities`
FOREIGN KEY (`city_id`)
REFERENCES `cities`(`city_id`);

ALTER TABLE `orders`
ADD CONSTRAINT `fk_orders_customers`
FOREIGN KEY (`customer_id`)
REFERENCES `customers`(`customer_id`);

ALTER TABLE `order_items`
ADD CONSTRAINT `pk_composite_orders_items`
PRIMARY KEY (`order_id`, `item_id`),
ADD CONSTRAINT `fk_order_items_items`
FOREIGN KEY (`item_id`)
REFERENCES `items`(`item_id`),
ADD CONSTRAINT `fk_orders_order_id`
FOREIGN KEY (`order_id`)
REFERENCES `orders`(`order_id`);

#5-2
create table `item_types`(
	`item_type_id` int primary key auto_increment,
	`name` varchar(50)
);

create table `items`(
	`item_id` int primary key auto_increment,
	`name` varchar(50),
	`item_type_id` int,
	foreign key (`item_type_id`)
	references `item_types`(`item_type_id`)
);

create table `cities`(
	`city_id` int primary key auto_increment,
	`name` varchar(50)
);

create table `customers`(
	`customer_id` int primary key auto_increment,
	`name` varchar(50),
	`birthday` date,
	`city_id` int,
	foreign key (`city_id`)
	references `cities`(`city_id`)
);

create table `orders`(
	`order_id` int primary key auto_increment,
	`customer_id` int,
	foreign key (`customer_id`)
	references `customers`(`customer_id`)
);

create table `order_items`(
	`order_id` int,
	`item_id` int,
	primary key (`order_id`, `item_id`),
	foreign key (`order_id`)
	references `orders`(`order_id`),
	foreign key (`item_id`)
	references `items`(`item_id`)
);


#6 

CREATE DATABASE `relations06`;
USE `relations06`;

CREATE TABLE `subjects` (
	`subject_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
    `subject_name` VARCHAR(50)
);

CREATE TABLE `majors`(
	`major_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50)
);

CREATE TABLE `payments`(
	`payment_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
    `payment_date` DATE,
    `payment_amount` DECIMAL(8,2),
    `student_id` INT(11)
);

CREATE TABLE `agenda`(
	`student_id` INT(11),
    `subject_id` INT(11),
    CONSTRAINT `composite_pk_agenda`
    PRIMARY KEY (`student_id`, `subject_id`)
);

CREATE TABLE `students`(
	`student_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
    `student_number` VARCHAR(12) UNIQUE,
    `student_name` VARCHAR(50),
    `major_id` INT (11)
);

ALTER TABLE `payments`
ADD CONSTRAINT `fk_payments_students`
FOREIGN KEY (`student_id`)
REFERENCES `students`(`student_id`);

ALTER TABLE `students`
ADD CONSTRAINT `fk_students_majors`
FOREIGN KEY (`major_id`)
REFERENCES `majors`(`major_id`);

ALTER TABLE `agenda`
ADD CONSTRAINT `fk_agenda_subjects`
FOREIGN KEY (`subject_id`)
REFERENCES `subjects`(`subject_id`),
ADD CONSTRAINT `fk_agenda_students`
FOREIGN KEY (`student_id`)
REFERENCES `students`(`student_id`);



#9 
USE `geography`;

SELECT `mountain_range`, `peak_name`, `elevation`
FROM `mountains`
JOIN `peaks`
ON `peaks`.`mountain_id` = `mountains`.`id`
WHERE `mountain_range` = "Rila"
ORDER BY `elevation` DESC;
