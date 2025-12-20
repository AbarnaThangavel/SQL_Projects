--1 which team has won the maximum gold medals over the years.

select top 1 team, count(distinct event) as no_of_gold
from athletes a inner join athlete_events ae on a.id = ae.athlete_id
where ae.medal = 'Gold'
group by team
order by no_of_gold desc

--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver

with agg_data as (
select team, year, count(distinct event) as total_silver_medals,
Rank()over(partition by team order by count(distinct event) desc) as rn
from athletes a inner join athlete_events ae on a.id = ae.athlete_id
where ae.medal = 'Silver'
group by team, year)

select team, sum(total_silver_medals) as total_silver_medals, max(case when rn=1 then year end) as year_of_max_silver
from agg_data 
group by team

--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years
with agg_data as (
select name,medal
from athletes a left join athlete_events ae on a.id=ae.athlete_id)
select name, count(medal) as no_of_gold_medals
from agg_data
where name  not in (select distinct name from agg_data where medal in ('Silver','Bronze')) and medal = 'Gold'
group by name 
order by no_of_gold_medals desc


--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.
with agg_data as(
select year,name,
sum(case when medal = 'Gold' then 1 else 0 end) as no_of_golds
from athlete_events ae inner join athletes a on a.id= ae.athlete_id
group by year,name),
rn_data as (
select *,
dense_rank()over (partition by year order by no_of_golds desc) as rn
from agg_data)
select year,no_of_golds ,STRING_AGG(name,',') as players
from rn_data
where rn= 1
group by year,no_of_golds

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,event

select * from (
select event,medal,year,
rank()over(partition by medal order by year asc) as rn
from athlete_events ae inner join athletes a on a.id = ae.athlete_id
where team = 'India' and medal <> 'NA'
group by event, medal,year) a 
where rn = 1

--6 find players who won gold medal in summer and winter olympics both.

select name
from athlete_events ae inner join athletes a on a.id = ae.athlete_id
where medal = 'Gold'
group by name
having count(distinct season) = 2

----7 find players who won gold, silver and bronze medal in a single olympics. 
--print player name along with year.

select year,name
from athlete_events ae inner join athletes a on a.id = ae.athlete_id
where medal <> 'NA'
group by year,name
having count(distinct medal) = 3


--8 find players who have won gold medals in consecutive 3 summer olympics in the same event .
--Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
with agg_data as (
select event,name,year as current_yr
from athlete_events ae inner join athletes a on a.id = ae.athlete_id
where year >= 2000 and medal = 'Gold' and season ='Summer'),
rn_data as (
select *,
lag(current_yr,1) over (partition by event,name order by current_yr asc) as pvs_yr,
lead(current_yr,1) over (partition by event,name order by current_yr asc) as nxt_yr
from agg_data)
select * 
from rn_data
where current_yr = pvs_yr+4 and current_yr = nxt_yr-4










