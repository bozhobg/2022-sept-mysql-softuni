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
    foreign key (`discipline_id`) references `disciplines`(`id`)
    on delete cascade,
    foreign key (`athlete_id`) references `athletes`(`id`)
    on delete cascade,
    foreign key (`medal_id`) references `medals`(`id`)
    on delete cascade
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

#3
update `disciplines`
set `name` = replace(`name`, 'weight', '');

#4
# TODO add on delete and on update for foreign keys!
delete from `athletes`
where `age` > 35;


# Querying
#5
select c.`id`, c.`name`
from `countries` as `c`
left join `athletes` as `a`
on a.`country_id` = c.`id`
where a.`id` is null
order by c.`name` desc
limit 15;

#6
select 
	concat_ws(' ', a.`first_name`, a.`last_name`) as `full_name`,
    a.`age`
from `disciplines_athletes_medals` as `dam`
join `athletes` as `a`
on dam.`athlete_id` = a.`id`
order by a.`age`, a.`id` asc
limit 2
;

#7
select 
	a.`id`,
    a.`first_name`,
    a.`last_name`
from `athletes` as `a`
left join `disciplines_athletes_medals` as `dam`
on dam.`athlete_id` = a.`id`
where dam.`discipline_id` is null
order by a.`id` asc;

#8
select 
	a.`id`,
    a.`first_name`,
    a.`last_name`,
    count(dam.`medal_id`) as `medals_count`,
    s.`name`
from `sports` as `s`
join `disciplines` as `d`
on d.`sport_id` = s.`id`
join `disciplines_athletes_medals` as `dam`
on dam.`discipline_id` = d.`id`
join `athletes` as `a`
on a.`id` = dam.`athlete_id`
group by a.`id`, s.`name`
order by `medals_count` desc, a.`first_name` asc
limit 10;

#9
select 
	concat_ws(' ', a.`first_name`, a.`last_name`) as `full_name`,
    (case
		when a.`age` < 19 then 'Teenager'
        when a.`age` between 19 and 25 then 'Young adult'
        when a.`age` >= 26 then 'Adult'
        end 
    ) as `age_group`
from `athletes` as `a`
order by a.`age` desc, a.`first_name` asc;

#Programmability
#10
delimiter $$

create function `udf_total_medals_count_by_country`(`name` varchar(40))
returns int
deterministic
begin
	return  (
		select count(*)
		from `disciplines_athletes_medals` as `dam`
		join `athletes` as `a`
		on dam.`athlete_id` = a.`id`
		join `countries` as `c`
		on c.`id` = a.`country_id`
		group by c.`name`
		having c.`name` = `name`
        limit 1
	);
end
$$

delimiter ;

#11
delimiter $$

create procedure `udp_first_name_to_upper_case`(`letter` char(1))
begin
	update `athletes`
    set `first_name` = upper(`first_name`)
    where `first_name` like concat("%",`letter`);
end
$$

delimiter ;


