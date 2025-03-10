SET SESSION SQL_MODE='ALLOW_INVALID_DATES';

USE `book_library`;

#1
SELECT `title` FROM `books`
WHERE SUBSTRING(`title`, 1, 3) = "The";

#2
SELECT REPLACE (`title`, "The", "***") AS `title`
FROM `books`
ORDER BY `id`;

#3
SELECT ROUND(SUM(`cost`), 2)
FROM `books`;

#4
SELECT CONCAT_WS(" ", `first_name`, `last_name`) AS `Full Name`, 
TIMESTAMPDIFF(DAY, `born`, `died`) AS `Days Lived`
FROM `authors`;

#5
SELECT `title` FROM `books`
WHERE `title` LIKE "Harry Potter%"
ORDER BY `id`;

SELECT `title` FROM `books`
WHERE `title` REGEXP "Harry Potter[\w\s]*"
ORDER BY `id`;

#Test after usb mount 
USE `book_library`;
SELECT * FROM `authors`;

