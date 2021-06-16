create database fallintern;
use  fallintern;

/**
create table region_master(
region_code int not null,
region_name varchar(255) not null
);
insert into region_master values(1001,'Central');
insert into region_master values(2001,'Midwest');
**/

/**
create table product_master(
product_code int not null,
product_name varchar(255),
unit_price int,
valid_from_period varchar(255),
valid_to_period varchar(255)
);
insert into product_master values(101,'Product A',212,2019.10,2020.03);
insert into product_master values(101,'Product A',197,2020.04,2020.09);
insert into product_master values(101,'Product A',187,2020.10,current_date());
insert into product_master values(102,'Product B',220,2019.10,2020.03);
insert into product_master values(102,'Product B',207,2020.04,2020.09);
insert into product_master values(102,'Product B',194,2020.10,current_date());
insert into product_master values(103,'Product C',215,2020.10,current_date());
**/

/*
For creating table revenue used CSV import of work bench
*/

/**
select *from revenue;
select count(*) from revenue;
**/

/**
select *from region_master;
select count(*) from region_master;
**/

/**
select *from product_master;
select count(*) from product_master;
**/

/**
Q4- Query to display top product by Revenue in each region for both years
**/

/**
with t1 as
(select region,year,product,sum(`Revenue(Millions)`) as revenue from revenue
 group by region,product,year order by region,year,revenue desc),
t2 as
(select region,year,max(revenue) as max_rev from t1 group by region,year)
select t1.region,t1.year,t1.product,t1.revenue from t1 join t2 on t1.revenue=t2.max_rev;
**/

/**
Q1 - Query to display Revenue,Cost to Product and Net Revenue for each region for year 2020 and 2021
**/

/**
with t2 as
(select product_code,unit_price,str_to_date(valid_from_period,'%Y.%m') as s_date,
str_to_date(valid_to_period,'%Y.%m') as e_date from product_master),
t1 as
(select Region,Product,Year,str_to_date(concat(Year,'.',Month),'%Y.%m') as a_date,`Revenue(Millions)`,`Quantity Sold` from revenue),
t3 as
(select *,
case 
    when a_date between s_date and e_date then unit_price*`Quantity Sold` 
    when a_date>=s_date and e_date is null then unit_price*`Quantity Sold`
    end as cost_to_product
from t1 tone join region_master rm on tone.Region=rm.region_code join t2 ttwo on tone.Product=ttwo.product_code),
t4 as
(select Region,Product,Year,`Revenue(Millions)`*1000000 as revenue,`Quantity Sold`,cost_to_product,`Revenue(Millions)`*1000000- cost_to_product as net_revenue 
from t3 where cost_to_product is not null)
select Region,Year,sum(revenue) as revenue,sum(cost_to_product) as cost_to_product,sum(net_revenue) as net_revenue
from t4 group by Region,Year
**/

/**
Q2 - Query to display company's YTD Revenue, YTD cost to product, YTD Net Revenue for each month for both the years
**/
/**
with t2 as
(select product_code,unit_price,str_to_date(valid_from_period,'%Y.%m') as s_date,
str_to_date(valid_to_period,'%Y.%m') as e_date from product_master),
t1 as
(select Region,Product,Year,Month,str_to_date(concat(Year,'.',Month),'%Y.%m') as a_date,`Revenue(Millions)`,`Quantity Sold` from revenue),
t3 as
(select *,
case 
    when a_date between s_date and e_date then unit_price*`Quantity Sold` 
    when a_date>=s_date and e_date is null then unit_price*`Quantity Sold`
    end as cost_to_product
from t1 tone join region_master rm on tone.Region=rm.region_code join t2 ttwo on tone.Product=ttwo.product_code),
t4 as
(select Year,Month,sum(`Revenue(Millions)`*1000000) as revenue,sum(cost_to_product) as cost_to_product,
sum(`Revenue(Millions)`*1000000-cost_to_product) as net_revenue
from t3 where cost_to_product is not null group by 1,2)
select Year,Month,sum(revenue) over(order by Year,Month) as cum_revenue,
sum(cost_to_product) over(order by Year,Month) as cum_cost_to_product,
sum(net_revenue) over(order by Year,Month) as cum_net_revenue
from t4

with t2 as
(select product_code,unit_price,str_to_date(valid_from_period,'%Y.%m') as s_date,
str_to_date(valid_to_period,'%Y.%m') as e_date from product_master),
t1 as
(select Region,Product,Year,Month,str_to_date(concat(Year,'.',Month),'%Y.%m') as a_date,`Revenue(Millions)`,`Quantity Sold` from revenue),
t3 as
(select *,
case 
    when a_date between s_date and e_date then unit_price*`Quantity Sold` 
    when a_date>=s_date and e_date is null then unit_price*`Quantity Sold`
    end as cost_to_product
from t1 tone join region_master rm on tone.Region=rm.region_code join t2 ttwo on tone.Product=ttwo.product_code)
(select Year,Month,sum(`Revenue(Millions)`*1000000) as revenue,sum(cost_to_product) as cost_to_product,
sum(`Revenue(Millions)`*1000000-cost_to_product) as net_revenue
from t3 where cost_to_product is not null group by 1,2)
**/

/**
Q3 - Query to display Net Share of each product in Revenue for each region for Year 2020
**/
/**
with t2 as
(select product_code,unit_price,str_to_date(valid_from_period,'%Y.%m') as s_date,
str_to_date(valid_to_period,'%Y.%m') as e_date from product_master),
t1 as
(select Region,Product,Year,str_to_date(concat(Year,'.',Month),'%Y.%m') as a_date,`Revenue(Millions)`,`Quantity Sold` from revenue),
t3 as
(select *,
case 
    when a_date between s_date and e_date then unit_price*`Quantity Sold` 
    when a_date>=s_date and e_date is null then unit_price*`Quantity Sold`
    end as cost_to_product
from t1 tone join region_master rm on tone.Region=rm.region_code join t2 ttwo on tone.Product=ttwo.product_code),
t4 as
(select Region,Product,Year,sum(`Revenue(Millions)`*1000000-cost_to_product) as net_revenue
from t3 where cost_to_product is not null and Year=2020 group by 1,2,3),
t5 as
(select sum(net_revenue) as tot_rev from t4)
select Region,Product,Year,net_revenue/tot_rev as net_share 
from t4 join t5 order by Region
**/

/**
Q5-Query to display Average Rolling previous 3 months net revenue for each month and region
**/

/**
with t2 as
(select product_code,unit_price,str_to_date(valid_from_period,'%Y.%m') as s_date,
str_to_date(valid_to_period,'%Y.%m') as e_date from product_master),
t1 as
(select Region,Product,Year,Month,str_to_date(concat(Year,'.',Month),'%Y.%m') as a_date,`Revenue(Millions)`,`Quantity Sold` 
from revenue),
t3 as
(select *,
case 
    when a_date between s_date and e_date then unit_price*`Quantity Sold` 
    when a_date>=s_date and e_date is null then unit_price*`Quantity Sold`
    end as cost_to_product
from t1 tone join region_master rm on tone.Region=rm.region_code join t2 ttwo on tone.Product=ttwo.product_code),
t4 as
(select Region,Year,Month,sum(`Revenue(Millions)`*1000000-cost_to_product) as net_revenue,
row_number() over() as rnum from t3 where cost_to_product
 is not null group by 1,2,3 order by Region,Year,Month)
 select Region,Year,Month,net_revenue,avg(net_revenue) over(order by rnum ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as rolling_sum
 from t4
 
 with t2 as
(select product_code,unit_price,str_to_date(valid_from_period,'%Y.%m') as s_date,
str_to_date(valid_to_period,'%Y.%m') as e_date from product_master),
t1 as
(select Region,Product,Year,Month,str_to_date(concat(Year,'.',Month),'%Y.%m') as a_date,`Revenue(Millions)`,`Quantity Sold` 
from revenue),
t3 as
(select *,
case 
    when a_date between s_date and e_date then unit_price*`Quantity Sold` 
    when a_date>=s_date and e_date is null then unit_price*`Quantity Sold`
    end as cost_to_product
from t1 tone join region_master rm on tone.Region=rm.region_code join t2 ttwo on tone.Product=ttwo.product_code),
t4 as
(select Region,Year,Month,sum(`Revenue(Millions)`*1000000-cost_to_product) as net_revenue from t3 where cost_to_product
 is not null group by 1,2,3 order by 1,2,3),
 t5 as
( select Region,Month,sum(net_revenue) as net_revenue from t4  where Region=1001 group by 1,2 order by 1,2),
 t6 as
( select Region,Month,sum(net_revenue) as net_revenue from t4  where Region=2001 group by 1,2 order by 1,2)
select Region,Month,net_revenue,avg(net_revenue) over(order by Month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as rolling_revenue from t5
union
select Region,Month,net_revenue,avg(net_revenue) over(order by Month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as rolling_revenue from t6
**/
 
 
 
 
 

