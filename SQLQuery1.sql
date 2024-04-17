create database ds_salaries;

use ds_salaries;



select top 10 * from salaries


/* 1- You're a Compensation analyst employed by a multinational corporation. Your Assignment is to 
Pinpoint Countries who give work fully remotely, for the title 'managers’ Paying salaries Exceeding $90,000 USD */


select distinct company_location  from salaries
where job_title like '%Manager%'  and remote_ratio=100 and salary_in_usd >90000


/* 2- AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ 
clients IN large tech firms. you're tasked WITH Identifying top 5 Country Having greatest count 
of large (company size) number of companies. */

select top 5 company_location,count(company_location)as total  from salaries
where company_size='L' and experience_level='EN'
group by company_location
order by count(company_location) desc


/* 3- Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate 
the percentage of employees. Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the 
attractiveness of high-paying remote positions IN today's job market. */


with t1 as (
    select count(*) as remote_work
    from salaries
    where remote_ratio = 100 and salary_in_usd > 100000
),
t2 as (
    select count(*) as total
    from salaries
	where salary_in_usd > 100000
)
select remote_work * 100.0 / total as percentage_remote_work
from t1, t2;



/* 4- Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the Locations where 
entry-level average salaries exceed the average salary for that job title IN market for entry level, 
helping your agency guide candidates towards lucrative opportunities.*/



with t1 as (
    select job_title, avg(salary) as market_avg_salary 
    from salaries
    group by job_title
),

t2 as (
    select company_location, job_title, avg(salary) as job_avg_salary 
    from salaries
    group by job_title, company_location
)

select t1.job_title, company_location, market_avg_salary, job_avg_salary  
from t1
join t2 on t1.job_title = t2.job_title
where market_avg_salary > job_avg_salary;



/* 5 -You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. 
Your job is to Find out for each job title which. Country pays the maximum average salary. 
This helps you to place your candidates IN those countries. */

with main as(
			select *
			,row_number()over(partition by x.company_location,x.job_title order by x.avg_sal)as rn 
			from(
				select company_location,job_title,avg(salary)as avg_sal
				from salaries
				group by company_location,job_title)x)
	select * from main
	where rn=1
	and job_title='Admin & Data Analyst';



/* 5.AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends 
across different company Locations. Your goal is to Pinpoint Locations WHERE the average salary Has consistently
Increased over the Past few years (Countries WHERE data is available for 3 years Only(present year and past two years) 
providing Insights into Locations experiencing Sustained salary growth. */


select * from salaries

--i will make a tbale for three  years such as 2021,2022,2023

with sal_21 as(
		select company_location,avg(salary)as avg_sal_2021 from salaries
		where work_year='2021'
		group by  company_location),

	sal_22 as(
		select company_location,avg(salary)as avg_sal_2022 from salaries
		where work_year='2022'
		group by  company_location),

	sal_23 as(
		select company_location,avg(salary)as avg_sal_2023 from salaries
		where work_year='2023'
		group by  company_location)

select sal_21.company_location,avg_sal_2021,
	   	avg_sal_2022,avg_sal_2023
	
from sal_21
join sal_22 on sal_21.company_location =sal_22.company_location
join sal_23 on sal_21.company_location =sal_23.company_location 
where avg_sal_2023>avg_sal_2022 and avg_sal_2022>avg_sal_2021



/* 7-Picture yourself AS a workforce strategist employed by a global HR tech startup. Your Mission is to Determine 
the percentage of fully remote work for each experience level IN 2021 and compare it WITH the corresponding figures for 2024,
Highlighting any significant Increases or decreases IN remote work Adoption over the years.*/

select * from salaries

with per_21_exp as(
		select experience_level,count(experience_level)as ex_21 from salaries
		where work_year='2021' and remote_ratio=100
		group by experience_level),
	per_21_total as(
		select experience_level,count(experience_level)as total_21 from salaries
		where work_year='2021'
		group by experience_level),

	per_24_exp as(
			select experience_level,count(experience_level)as ex_24 from salaries
			where work_year='2024' and remote_ratio=100
			group by experience_level),
	per_24_total as(
		select experience_level,count(experience_level)as total_24 from salaries
		where work_year='2024'
		group by experience_level)

select per_21_exp.experience_level,
	   (ex_21*100/total_21) as percentage_21,
	   (ex_24*100/total_24) as percentage_24
from per_21_exp
join per_21_total on per_21_exp.experience_level=per_21_total.experience_level
join per_24_exp   on per_21_exp.experience_level=per_24_exp.experience_level
join per_24_total on per_21_exp.experience_level=per_24_total.experience_level



/* 8- AS a Compensation specialist at a Fortune 500 company, you're tasked WITH analyzing salary trends over time. 
Your objective is to calculate the average salary increase percentage for each experience level and job title between 
the years 2023 and 2024, helping the company stay competitive IN the talent market. */


select * from salaries

with exp_23 as(
		select experience_level,job_title,avg(salary)as avg_sal_23 from salaries
		where work_year='2023'
		group by experience_level,job_title),
	exp_24 as(
		select experience_level,job_title,avg(salary)as avg_sal_24 from salaries
		where work_year='2024'
		group by experience_level,job_title)
select exp_23.experience_level,exp_23.job_title,
	   avg_sal_23,avg_sal_24  
from exp_23 
join exp_24 on exp_23.experience_level=exp_24.experience_level
			and exp_23.job_title=exp_24.job_title
where avg_sal_24>avg_sal_23


/* 9- You are working with a consultancy firm, your client comes to you with certain data and preferences such 
as (their year of experience , their employment type, company location and company size )  
and want to make an transaction into different domain in data industry (like  a person is working as a 
data analyst and want to move to some other domain such as data science or data engineering etc.) 
your work is to  guide them to which domain they should switch to base on  the input they provided, 
so that they can now update their knowledge as  per the suggestion/.. The Suggestion should be based on average salary */



with domain_avg_salary as (
    select 
        job_title,
        avg(salary_in_usd) as avg_salary
    from 
        salaries
    where 
        work_year = '2024'
        and experience_level = 'SE' 
        and employment_type = 'FT' 
        and company_location = 'US' 
    group by 
        job_title
)
select top 1
    job_title,
    avg_salary
from 
    domain_avg_salary
order by 
    avg_salary desc










