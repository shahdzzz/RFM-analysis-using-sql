-- so first we need to check revenue and get top 10 countries in revenue 
select * from (
select distinct country as country, sum (quantity*unitprice) as revenu,
        dense_rank () over (order by sum (quantity*unitprice) desc ) as rnk
from online_retail 
group by country
order by rnk) as r
where r.rnk <=10;

-----------------------------------------------------------------------------
--What is the highest month for revenue?
SELECT extract(month FROM invoicedate) AS month
	,sum(quantity * unitprice) AS revenue
	,RANK() OVER (
		ORDER BY SUM(quantity * unitprice) DESC
		) AS month_rank
		
FROM online_retail
WHERE invoicedate <= '11-30-2011'
GROUP BY extract(month FROM invoicedate)
ORDER BY revenue DESC;

--------------------------------------------------------------------
--lets know the country which have the highest and lowest number of customers to define the problem more 

select count (distinct customerid)as customer_count, country,
        dense_rank () over (order by count( distinct customerid) desc ) as rank
from online_retail
group by country;

----------------------------------------------------------------------
---highest product per each country

select distinct (description) as highest_product, country,
        last_value (count (description)) over (partition by (country)
                    order by (count (description))
                    rows between unbounded preceding and unbounded following) as product_count
from online_retail
group by description, country;

-------------------------------------------------------------
--now we need to know how many costumer visit our store daily per country :

select count (distinct customerid) as customer_count, country, invoicedate as day_date,
          dense_rank () over (order by count( distinct customerid) desc) as rank
from online_retail
group by country,invoicedate
order by rank;

