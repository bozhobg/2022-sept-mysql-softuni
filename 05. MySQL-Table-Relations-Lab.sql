use `camp`;

create database `test2`;
use `test2`;

#1
create table `mountains`(
	`id` int primary key auto_increment,
    `name` varchar(30) not null
);

create table `peaks`(
	`id` int primary key auto_increment,
    `name` varchar(30) not null,
    `mountain_id` int not null,
    constraint `fk_peaks_mountain_id`
    foreign key (`mountain_id`)
    references `mountains`(`id`)
);

drop table `mountains`, `peaks`;

create table `mountains`(
	`id` int primary key auto_increment,
    `name` varchar(30) not null
);

create table `peaks`(
	`id` int primary key auto_increment,
    `peak` varchar(30) not null,
    `mountain_id` int not null
    );
    
alter table `peaks`
add constraint `fk_peaks_mountains`
foreign key (`mountain_id`)
references `mountains`(`id`);


#2
select `driver_id`, `vehicle_type`, 
	concat(`first_name`, " ", `last_name`) as "driver_name"
from `campers`
join `vehicles`
`vehicles`.`id` = `campers`.`vehicle_id`;

select `driver_id`, `vehicle_type`,
	concat(`first_name`, " ", `last_name`) as "driver_name"
from `vehicles` as `v`
join `campers` as `c`
on `v`.`driver_id` = `c`.`id`;


#3
select 
	`starting_point`,
    `end_point`,
    `leader_id`,
    concat(`first_name`, " ", `last_name`) as `leader_name`
from `routes` as `r`
join `campers` as `c`
on `r`.`leader_id` = `c`.`id`;



#4
use `test2`;

create table `mountains`(
	`id` int primary key auto_increment,
    `name` varchar(30) not null
);

create table `peaks`(
	`id` int primary key auto_increment,
    `name` varchar(30) not null,
    `mountain_id` int not null,
    constraint `fk_peaks_mountain_id`
    foreign key (`mountain_id`)
    references `mountains`(`id`)
    on delete cascade
);



	
#5
create table `clients`(
	`id` int(11) primary key auto_increment,
    `client_name` varchar(100)
);

create table `projects`(
	`id` int(11) primary key auto_increment,
    `client_id` int(11),
    `project_lead` int(11)
);

create table `employees`(
	`id` int primary key auto_increment,
    `first_name` varchar(30),
    `last_name` varchar(30),
    `project_id` int(11)
);

alter table `projects`
add constraint `fk_projects_clients`
foreign key (`client_id`)
references `clients`(`id`),
add constraint `fk_projects_employees`
foreign key (`project_lead`)
references `employees`(`id`);	

alter table `employees`
add constraint `fk_employees_projects`
foreign key (`project_id`)
references `projects`(`id`);
