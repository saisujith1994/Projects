--find the top 10 revenue generating products

select top 10 product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc

-- find the highest selling 5 products per each region

with cte as(
select region, product_id, sum(sale_price) as sales
from df_orders
group by region, product_id
)
select * from (select *,ROW_NUMBER() over(partition by region order by sales desc) as rn
from cte)A
where rn in (1,2,3,4,5)

-- find month and month comparision for the year 2022 and 2023 like Jan-2022 V/S Jan-2023
with cte as(
select year(order_date) as order_year, month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date), month(order_date)
	)
select order_month,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month

-- for each category which month had highest sales
with cte as(
select category,sum(sale_price) as sales,format(order_date,'yyyyMM') as order_year_month 
from df_orders
group by category,format(order_date,'yyyyMM')
)
select category,order_year_month,sales from(select *,ROW_NUMBER() over(partition by category order by sales desc) as rn
from cte)A
where rn=1

--which sub category has highest growth by profit in 2023 compare to 2022

with cte as(
select sub_category,year(order_date) as order_year,
sum(profit) as total_profit
from df_orders
group by sub_category,year(order_date)
	)
select top 1 sub_category,profit_2023-profit_2022 as profit_diff from
(select sub_category,
sum(case when order_year=2022 then total_profit else 0 end) as profit_2022,
sum(case when order_year=2023 then total_profit else 0 end) as profit_2023
from cte
group by sub_category)A
order by profit_diff desc
