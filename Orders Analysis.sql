CREATE TABLE orders(
	[order_id] int primary key,
	[order_date] date,
	[ship_mode] varchar(20),
	[segment] varchar(20),
	[country] varchar(20),
	[city] varchar(20),
	[state] varchar(20),
	[postal_code] varchar(20),
	[region] varchar(20),
	[category] varchar(20),
	[sub_category] varchar(20),
	[product_id] varchar(20),
	[quantity] int,
	[discount] decimal(7,2),
	[sale_price] decimal(7,2),
	[profit] decimal(7,2)
)

SELECT * FROM orders

--Top 10 Highest revenue genearting products
SELECT TOP 10 product_id,sum(sale_price*quantity) as revenue
FROM orders
GROUP BY product_id
ORDER BY revenue DESC

--Top 5 highest selling products in each region
WITH CTE as(
SELECT region,product_id,sum(quantity) as sold_quantity
FROM orders
GROUP BY region,product_id)
SELECT * FROM(
SELECT* ,ROW_NUMBER() OVER(PARTITION BY region order by sold_quantity DESC) as product_rank
FROM CTE) A
WHERE product_rank<=5

--Month Over month comparison
WITH CTE AS(
SELECT YEAR(order_date) as order_year ,MONTH(order_date) as month_order,
SUM(quantity) AS sales
FROM orders
GROUP BY YEAR(order_date),month(order_date)
)
SELECT month_order, sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
FROM CTE
group by month_order
order by month_order

--Month Wise Sales for each category
WITH CTE AS(
SELECT category,FORMAT(order_date,'yyyyMM') as order_year_month,
sum(quantity) as sales
from orders
group by category,FORMAT(order_date,'yyyyMM')
)
SELECT * from (
select*,row_number() OVER(PARTITION BY category order by sales desc) as Rnk
from cte
) A
WHERE RNK=1

--HIGHEST GROWTH BY PROFIT FOR SUBCATEGORY PER YEAR 
WITH CTE AS(
SELECT sub_category,YEAR(order_date) as order_year ,
SUM(quantity*sale_price) AS sales
FROM orders
GROUP BY sub_category,YEAR(order_date),month(order_date)
)
, CTE2 AS(
SELECT sub_category, sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
FROM CTE
group by sub_category
)
SELECT top 1*
,(sales_2023-sales_2022)*100/sales_2022 as Profit
from cte2
order by (sales_2023-sales_2022)*100/sales_2022 desc