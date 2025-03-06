create database `summer_olympics`;
use `summer_olympics`;

create table `countries`(
	`id` int primary key auto_increment,
    `name` varchar(40) not null unique
);

create table `sports`(
	`id` int primary key auto_increment,
    `name` varchar(20) not null unique
);

create table `disciplines`(
	`id` int primary key auto_increment,
    `name` varchar(40) not null unique,
    `sport_id` int not null,
    foreign key (`sport_id`) references `sports`(`id`)
);

create table `athletes`(
	`id` int primary key auto_increment,
    `first_name` varchar(40) not null,
    `last_name` varchar(40) not null,
    `age` int not null,
    `country_id` int not null,
    foreign key (`country_id`) references `countries`(`id`)
);

create table `medals`(
	`id` int primary key auto_increment,
    `type` varchar(10) not null unique
);

# TODO this gives chance to create 2 medals in 1 discipline for the same athlete
create table `disciplines_athletes_medals`(
	`discipline_id` int not null,
    `athlete_id` int not null,
    `medal_id` int not null,
    primary key (`discipline_id`, `medal_id`),
    foreign key (`discipline_id`) references `disciplines`(`id`),
    foreign key (`athlete_id`) references `athletes`(`id`),
    foreign key (`medal_id`) references `medals`(`id`)
);

#2
insert into `athletes`(`first_name`, `last_name`, `age`, `country_id`)
(
	select 
		upper(a.`first_name`), 
		concat_ws(' ', a.`last_name`, 'comes from', c.`name`), 
        `age` + c.`id`, 
        `country_id`
    from `athletes` as `a`
    join `countries` as `c`
	on c.`id` = a.`country_id`
    where c.`name` like 'A%'
);


