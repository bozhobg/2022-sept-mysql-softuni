#DDL
drop database food_friends;
create database food_friends;
use food_friends;


#1
create table `restaurants`(
	`id` int primary key auto_increment,
    `name` varchar(40) not null unique,
    `type` varchar(20) not null,
    `non_stop` boolean not null
);

create table `offerings`(
	`id` int primary key auto_increment,
    `name` varchar(40) not null unique,
    `price` decimal(19,2) not null,
    `vegan` boolean not null,
    `restaurant_id` int not null,
    foreign key (`restaurant_id`) 
    references `restaurants`(`id`)
    on delete cascade
);

create table `customers`(
	`id` int primary key auto_increment,
    `first_name` varchar(40) not null,
    `last_name` varchar(40) not null,
    `phone_number` varchar(20) unique not null,
    `regular` boolean not null,
    # guarantees uniqueness of values in 2 cols combined
    unique (`first_name`, `last_name`) 
);

create table `orders`(
	`id` int primary key auto_increment,
    `number` varchar(10) unique not null,
    `priority` varchar(10) not null,
    `customer_id` int not null,
    `restaurant_id` int not null,
    constraint `fk_customers` foreign key (`customer_id`) 
    references `customers`(`id`)
    on delete cascade,
    constraint `fk_restaurant` foreign key (`restaurant_id`)
    references `restaurants`(`id`)
    on delete cascade
);

create table `orders_offerings`(
	`order_id` int not null,
    `offering_id` int not null,
    `restaurant_id` int not null,
    primary key(`order_id`, `offering_id`),
    constraint `fk_orders`
    foreign key (`order_id`) references `orders`(`id`)
    on delete cascade,
    constraint `fk_offerings`
    foreign key (`offering_id`) references `offerings`(`id`)
    on delete cascade,
    constraint `fk_restaurants`
    foreign key (`restaurant_id`) references `restaurants`(`id`)
    on delete cascade
);

#DML
#2
insert into `offerings`(
	`name`, 
    `price`,
    `vegan`,
    `restaurant_id`
) (
	select 
		concat(o.`name`, ' costs:'),
        o.`price`,
        o.`vegan`,
        o.`restaurant_id`
    from `offerings` as `o`
    where o.`name` like 'Grill%'
); 

#3
update `offerings`
set `name` = upper(`name`)
where `name` like '%Pizza%';

#4
delete from `restaurants`
where (`name` like '%fast%')
	or (`type` like '%fast%');

# Querying
#5
select o.`name`, o.`price`
from `offerings` as `o`
join `restaurants` as `r`
on o.`restaurant_id` = r.`id`
where r.`name` = 'Burger Haven'
order by o.`id` asc;

#6
select 
	c.`id`,
    c.`first_name`,
    c.`last_name`
from `customers` as `c`
left join `orders` as `o`
on o.`customer_id` = c.`id`
where o.`customer_id` is null
order by c.`id` asc;

#7
select 
	ofs.`id`,
    ofs.`name`
from `orders_offerings` as `oo`
join `orders` as `ors`
on ors.`id` = oo.`order_id`
join `customers` as `c`
on c.`id` = ors.`customer_id`
join `offerings` as `ofs`
on ofs.`id` = oo.`offering_id`
where concat_ws(' ', c.`first_name`, c.`last_name`) = 'Sofia Sanchez'
	and ofs.`vegan` is false
order by ofs.`id` asc;

#8-1 
# direct join of (restaurant - offerints), (restaurants-orders-customers)
select 
	r.`id`,
    r.`name`
from `restaurants` as `r`
join `orders` as `ors`
on ors.`restaurant_id` = r.`id`
join `customers` as `c`
on c.`id` = ors.`customer_id`
join `offerings` as `ofs`
on ofs.`restaurant_id` = r.`id`
where c.`regular` is true
	and ofs.`vegan` is true
    and ors.`priority` = 'HIGH'
group by r.`id`
having count(c.`id`) > 0
order by r.`id` asc;

#8-2
# linking offerings with restaurants through orders_offerings - orders
# you might not have orders with vegan offerings
select 
	r.`id`,
    r.`name`
from `restaurants` as `r`
join `orders` as `ors`
on ors.`restaurant_id` = r.`id`
join `customers` as `c`
on c.`id` = ors.`customer_id`
join `orders_offerings` as `oo`
on ors.`id` = oo.`order_id`
join `offerings` as `ofs`
on oo.`offering_id` = ofs.`id`
where c.`regular` is true
	and ofs.`vegan` is true
    and ors.`priority` = 'HIGH'
group by r.`id`
having count(c.`id`) > 0
order by r.`id` asc;    
    
#9
select 
	ofs.`name`,
    (
		case 
			when `price` <= 10 then 'cheap'
            when (`price` > 10 and `price` <= 25) then 'affordable'
            when `price` > 25 then 'expensive'
		end
    ) as `price_category`
from `offerings` as `ofs`
order by ofs.`price` desc, ofs.`name` asc;

#Programmability
#10
delimiter $$

create function `udf_get_offerings_average_price_per_restaurant`(
	`restaurant_name` varchar(40)
)
returns decimal(19,2)
deterministic
begin
	return (
		select avg(ofs.price)
        from `restaurants` as `r`
        join `offerings` as `ofs`
        on ofs.`restaurant_id` = r.`id`
        where r.`name` = `restaurant_name`
        group by r.`id`
    );
end
$$

delimiter ;

#11
delimiter $$

create procedure `udp_update_prices`(`restaurant_type` varchar(40))
begin
	update `offerings`
    set `price` = `price` + 5.00
    where `restaurant_id` in (
		select `id`
        from `restaurants`
        where `type` = `restaurant_type`
			and `non_stop` is true
    );
end
$$

delimiter ;