drop database `go_roadie`;
create database `go_roadie`;
use `go_roadie`;

#DDL
#1

create table `cities`(
	`id` int primary key auto_increment,
    `name` varchar(40) not null unique
);

create table `cars`(
	`id` int primary key auto_increment,
    `brand` varchar(20) not null,
    `model` varchar(20) not null unique
);

create table `instructors`(
	`id` int primary key auto_increment,
    `first_name` varchar(40) not null,
    `last_name` varchar(40) not null unique,
    `has_a_license_from` date not null
);

create table `driving_schools`(	
	`id` int primary key auto_increment,
    `name` varchar(40) not null unique,
    `night_time_driving` boolean not null,
    `average_lesson_price` decimal(10,2),
    `car_id` int not null,
    `city_id` int not null,
    foreign key (`car_id`) references `cars`(`id`),
    foreign key (`city_id`) references `cities`(`id`)
);

create table `students`(
	`id` int primary key auto_increment,
    `first_name` varchar(40) not null,
    `last_name` varchar(40) not null unique,
    `age` int,
    `phone_number` varchar(20) unique
);

create table `instructors_driving_schools`(
	`instructor_id` int,
    `driving_school_id` int not null,
    foreign key (`instructor_id`) 
    references `instructors`(`id`),
    foreign key (`driving_school_id`) 
    references `driving_schools`(`id`)
    on delete cascade
);

create table `instructors_students`(
	`instructor_id` int not null,
    `student_id` int not null,
    foreign key (`instructor_id`) 
    references `instructors`(`id`),
    foreign key (`student_id`) 
    references `students`(`id`)
);

#DML

#2

insert into `students`(
	`first_name`,
    `last_name`,
    `age`,
    `phone_number`
)(
	select 
		lower(reverse(s.`first_name`)) as `first_name`,
		lower(reverse(s.`last_name`)) as `last_name`,
		s.`age` + cast(left(s.`phone_number`, 1) as unsigned) as `age`,
		concat("1+", s.`phone_number`) as `phone_number`
	from `students` as `s`
	where s.`age` < 20
);

#3

update `driving_schools`
set `average_lesson_price` = `average_lesson_price` + 30
where `night_time_driving` is true 
	and `city_id` = (
		select c.`id` 
		from `cities` as `c` 
		where c.`name` = 'London'
        limit 1
	);

#4
delete from `driving_schools`
where `night_time_driving` is false;

#Querying

#5
select 
	concat_ws(' ', s.`first_name`, s.`last_name`) as `full_name`,
	s.`age`
from `students` as `s`
where s.`first_name` like "%a%"
	and s.`age` = (
		select min(s2.`age`)
        from `students` as `s2`
    )
order by s.`id` asc;

#6

select 
	ds.`id`,
    ds.`name`,
    c.`brand`
from `driving_schools` as `ds`
left join `instructors_driving_schools` as `ids`
on ids.`driving_school_id` = ds.`id`
join `cars` as `c`
on c.`id` = ds.`car_id`
where ids.`instructor_id` is null
order by c.`brand`, ds.`id` 
limit 5;

#7-1 -> use of having without group by?

select 
	i.`first_name`,
    i.`last_name`,
    (
		select count(*)
        from `instructors_students` as `is`
        where `is`.`instructor_id` = i.`id`
    ) as `student_count`,
    c.name
from `instructors` as `i`
join `instructors_driving_schools` as `ids`
on i.`id` = ids.`instructor_id`
join `driving_schools` as `ds`
on ds.`id` = ids.`driving_school_id`
join `cities` as `c`
on c.`id` = ds.`city_id`
# using having w/out group by
having `student_count` > 1
order by `student_count` desc, i.`first_name`
; 

#7-2 -> group by multiple columns
# direction of join ... on t1.col1 = t2.col2 OR t2.col2 = t1.col1 matters 
# -> produces different results
# how do you travel along the join tree ? 

select 
	i.`first_name`,
    i.`last_name`,
    count(`is`.`student_id`) as `students_count`,
    c.`name`
from `instructors` as `i`
join `instructors_students` as `is`
on i.`id` = `is`.`instructor_id`
join `instructors_driving_schools` as `ids`
on i.`id` = ids.`instructor_id`
join `driving_schools` as `ds`
on ids.`driving_school_id` = ds.`id`
join `cities` as `c`
on ds.`city_id` = c.`id`
# include second shown column
group by i.`id`, c.`name`
having `students_count` > 1
order by `students_count` desc, i.`first_name` asc
;

#7-3 
# using subselect to match instructors to corresponding city through driving school map
# avoiding multiple group by -> not fully understanding why multiple group by i.id, i.first_name, c.name the only one working properly

select 
	i.`first_name`,
    i.`last_name`,
    count(`is`.`student_id`) as `students_count`,
	(
		select c.`name`
        from `cities` as `c`
        join `driving_schools` as `ds`
        on ds.`city_id` = c.`id`
        join `instructors_driving_schools` as `ids`
        on ids.`driving_school_id` = ds.`id`
        where i.`id` = ids.`instructor_id`
        # considering one-to-one instructor - driving school map
        # limit 1
    ) as `city`
from `instructors` as `i`
join `instructors_students` as `is`
on `is`.`instructor_id` = i.`id`
group by i.`id`
having `students_count` > 1
order by 
	`students_count` desc,  
	i.`first_name` asc
;

#8-1 group by cities.name to get correct order of equal count cities
select 
	c.`name`,
    count(ids.`instructor_id`) as `instructors_count`
from `cities` as `c`
join `driving_schools` as `ds`
on c.`id` = ds.`city_id`
join `instructors_driving_schools` as `ids`
on ds.`id` = ids.`driving_school_id`
where ids.`instructor_id` is not null
group by c.`name`
having `instructors_count` > 0
order by `instructors_count` desc
;

#8-2
select 
	c.`name`,
    count(ids.`instructor_id`) as `instructors_count`
from `instructors_driving_schools` as `ids`
join `driving_schools` as `ds`
on ids.`driving_school_id` = ds.`id`
join `cities` as `c`
on ds.`city_id` = c.`id`
where ids.`instructor_id` is not null
group by c.`name`
order by `instructors_count` desc
;

#9

select 
	concat_ws(' ', i.`first_name`, i.`last_name`) as `full_name`,
    (
		case
			when year(i.`has_a_license_from`) >= 1980 and year(i.`has_a_license_from`) < 1990
            then 'Specialist'
            when year(i.`has_a_license_from`) >= 1990 and year(i.`has_a_license_from`) < 2000
            then 'Advanced'
            when year(i.`has_a_license_from`) >= 2000 and year(i.`has_a_license_from`) < 2008
            then 'Experienced'
            when year(i.`has_a_license_from`) >= 2008 and year(i.`has_a_license_from`) < 2015
            then 'Qualified'
            when year(i.`has_a_license_from`) >= 2015 and year(i.`has_a_license_from`) < 2020
            then 'Provisional'
            when year(i.`has_a_license_from`) >= 2020
            then 'Trainee'
        end
    ) as `level`
from `instructors` as `i`
order by year(i.`has_a_license_from`) asc, i.`first_name`
;

#Programmability
#10

delimiter $$

create function `udf_average_lesson_price_by_city`(`name` varchar(40))
returns decimal(10,2)
deterministic
begin
	declare `total_average` decimal(10,2);
    
    set `total_average` = (
		select avg(ds.`average_lesson_price`)
		from `cities` as `c`
		join `driving_schools` as `ds`
		on c.`id` = ds.`city_id`
		where c.`name` = `name`
		group by c.`id`
	);
        
	return `total_average`;
end
$$

delimiter ;

#11

delimiter $$

create procedure `udp_find_school_by_car`(`brand` varchar(20))
begin
	select 
		ds.`name`,
		ds.`average_lesson_price`
	from `driving_schools` as `ds`
	join `cars` as `cr`
	on ds.`car_id` = cr.`id`
	where cr.`brand` = `brand`
	order by ds.`average_lesson_price` desc;
end
$$

delimiter ;
