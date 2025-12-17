--1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

--Solution 1 - Subquery 
select top 5 city, sum(amount) as spends,
sum(amount)/(select sum(amount) from credit_card_transcations) * 100 as total_spends_percentage
from credit_card_transcations
group by city
order by spends desc

--Solution 2 - CTE with Window Functions
with city_wise_spend as 
(select city,sum(amount) as spends
from credit_card_transcations
group by city)

select top 5* ,spends/(sum(spends)over())*100 as total_spends_percent
from city_wise_spend
order by spends desc

--2- write a query to print highest spend month and amount spent in that month for each card type

with agg_data as 
(select card_type, DATEPART(year,transaction_date) as yr,DATEPART(month,transaction_date) as mnth,
sum(amount) as spends
from credit_card_transcations
group by card_type, DATEPART(year,transaction_date), DATEPART(month,transaction_date))
, rn_data as 
(select * ,
ROW_NUMBER()over(partition by card_type order by spends desc) as rn
from agg_data)
select * from rn_data where rn=1

--3- write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
with agg_data as(
select *,
sum(amount)over(partition by card_type order by transaction_date,
transaction_id) as cumm_amt
from credit_card_transcations)
,rn_data as (
select *,
ROW_NUMBER()over(partition by card_type order by cumm_amt asc) as rn
from agg_data
where cumm_amt >= 1000000)
select * from rn_data where rn=1

--4- write a query to find city which had lowest percentage spend for gold card type
with agg_data as (
select city, sum(amount) as total_spends,
sum(case when card_type = 'Gold' then amount end ) as gold_spend
from credit_card_transcations
group by city)

select top 1
* , gold_spend/total_spends * 100 as percent_goldspend
from agg_data
where gold_spend is not null
order by percent_goldspend asc

--5- write a query to print 3 columns:
--city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
with agg_data as(
select city, exp_type, sum(amount) as spends
from credit_card_transcations
group by city, exp_type),
rn_data as 
(select *, ROW_NUMBER() over(partition by city order by spends desc) as high_rn,
 ROW_NUMBER() over(partition by city order by spends asc) as low_rn
from agg_data)

select city,
max(case when high_rn = 1  then exp_type end) as highest_expense_type,
min(case when low_rn = 1  then exp_type end) as lowest_expense_type
from rn_data
where high_rn = 1 or low_rn = 1
group by city

--6- write a query to find percentage contribution of spends by females for each expense type

select exp_type, 
sum(case when gender = 'F' then amount else 0 end )/ sum(amount) * 100 as female_contrib 
from credit_card_transcations
group by exp_type
order by female_contrib desc

--7- which card and expense type combination saw highest month over month growth in Jan-2014
with agg_data as(
select  DATEPART(year,transaction_date) as yr,DATEPART(month,transaction_date) as mnth,
card_type,exp_type,sum(amount) as spends
from credit_card_transcations
group by DATEPART(year,transaction_date),DATEPART(month,transaction_date),
card_type,exp_type)
,pvs_data as(
select *,
lag(spends)over(partition by card_type,exp_type order by yr,mnth) as pvs_mnth
from agg_data)
select top 1*,
(spends - pvs_mnth)as mom
from pvs_data
where yr=2014 and mnth = 1
order by mom desc

-- 9- during weekends which city has highest total spend to total no of transcations ratio 
select top 1 city, sum(amount)/count(transaction_id) as ratio
from credit_card_transcations
where DATEPART(WEEKDAY,transaction_date) in (7,1)
group by city
order by ratio desc

--10- which city took least number of days to reach its 500th transaction after the first transaction in that city

with rn_data as
(select *,
ROW_NUMBER()over(partition by city order by transaction_date) as rn
from credit_card_transcations)
, agg_data as
(select city,
datediff(day,(min(case when rn = 1 then transaction_date end )),(min(case when rn = 500 then transaction_date end ))) as no_of_days
from rn_data 
group by city)
select top 1 city, no_of_days 
from agg_data 
where no_of_days is not null
order by no_of_days asc


