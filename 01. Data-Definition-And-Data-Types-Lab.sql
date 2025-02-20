CREATE DATABASE `gamebar`;

USE `gamebar`;

#PROBLE 1

CREATE TABLE `employees` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(250) NOT NULL,
`last_name` VARCHAR(250) NOT NULL
);

CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(255) NOT NULL
);

CREATE TABLE `products`(
`id` INT PRIMARY KEY NOT NULL,
`name` VARCHAR(255) NOT NULL,
`category_id` INT NOT NULL
);

#PROBLEM 2

INSERT INTO `employees` (`first_name`, `last_name`)
VALUES 
('drago', 'dragov'),
('ivan', 'ivanov'),
('gosho','goshov');

#PROBLEM 3

ALTER TABLE `employees`
ADD COLUMN `middle_name` VARCHAR(255);

#PROBLEM 4

ALTER TABLE `products`
ADD CONSTRAINT `fk_products_categories`
FOREIGN KEY (`category_id`)
REFERENCES `categories`(`id`);

#PROBLEM 5

ALTER TABLE `employees`
MODIFY COLUMN `middle_name` VARCHAR(100);
