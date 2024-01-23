SELECT TOP (1000) [id]
      ,[first_name]
      ,[last_name]
      ,[birthdate]
      ,[gender]
      ,[race]
      ,[department]
      ,[jobtitle]
      ,[location]
      ,[hire_date]
      ,[termdate]
      ,[location_city]
      ,[location_state]
  FROM [HR].[dbo].[HR Data]

  Use [HR]
  Select * From [HR Data]

  SELECT termdate FROM [HR Data]
  ORDER BY termdate DESC

  UPDATE [HR Data]
  SET termdate =FORMAT(CONVERT(DATETIME, LEFT (termdate,19), 120),'yyyy-MM-dd')

  ALTER TABLE [HR Data]
  ADD new_termdate DATE;

  UPDATE [HR Data]
  SET new_termdate = CASE 
  WHEN termdate IS NOT NULL AND ISDATE(termdate)=1 THEN CAST (termdate AS datetime) ELSE NULL END;

  --Create a new column for age 
  ALTER TABLE [HR Data]
  ADD age nvarchar(50);

  --Populate new column age
  UPDATE [HR Data]
  SET age = DATEDIFF(YEAR, birthdate, GETDATE());

  Select age from [HR Data]
  

  --What is the age distribution in the company?
  --age distribution

  Select 
  MIN(age) as Youngest,
  MAX(age) as Oldest
  From [HR Data]

  --age group distribution
  
  Select age From [HR Data]
  Order BY age ASC

  Select age_group,
  count(*) As count 
  From 
  (Select 
   CASE 
       WHEN age <= 21 AND age <= 30 THEN '21 to 30'
	   WHEN age <= 31 AND age <= 40 THEN '31 to 40'
	   WHEN age <= 41 AND age <= 50 THEN '41 to 50'
	   ELSE '50+'
	   END as age_group
   FROM [dbo].[HR Data]	
   WHERE new_termdate is NULL
   ) As subquery
 Group By age_group
   Order By age_group;
   
  ---Age Group by gender

  Select age_group,
  gender,
  count(*) As count
  From
  (Select 
      Case
	     WHEN age <= 21 AND age <= 30 THEN '21 to 30'
		 WHEN age <= 31 AND age <= 40 THEN '31 to 40'
	     WHEN age <= 41 AND age <= 50 THEN '41 to 50'
	     ELSE '50+'
		 END as age_group,
		 gender
      From [dbo].[HR Data]
	  Where new_termdate is NULL) AS subquery
	  Group by age_group, gender
	  Order by age_group, gender;

-- What's the gender breakdown in company

Select gender, 
count (gender) as count 
from[dbo].[HR Data]
Where new_termdate is NULL
Group By gender
Order By gender;

-- How does gender vary across departments and job titles?

Select gender,department,jobtitle,
count(*) as count
From [dbo].[HR Data]
Where new_termdate is NULL
Group By gender, department, jobtitle
order By gender, department, jobtitle;

-- What'e the race distribution in compnay?

Select race,
count(*) As count 
from [dbo].[HR Data]
Where new_termdate is NULL
Group By race
Order by count;

-- What's the average length of employment in the company?

Select 
Avg(Datediff(Year, hire_date, new_termdate)) As tenure
From[dbo].[HR Data]
Where new_termdate IS NOT NULL AND new_termdate <= GETDATE();

-- Which department has the highest turnover rate ?
--get total count
-- get terminated count
--terminated count/total count

Select department,
total_count,
term_count,
Round((CAST(term_count AS float) / total_count),2) *100 As tenure
From
(Select department,
count(*) As total_count,
SUM(CASE
   WHEN new_termdate is NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0
   END
   ) AS term_count
From [dbo].[HR Data]
Group By department
) As sub_query
Order By tenure 

-- What is the tenure distribution for each department?

Select 
department,
Avg(Datediff(Year, hire_date, new_termdate)) As tenure
From[dbo].[HR Data]
Where new_termdate IS NOT NULL AND new_termdate <= GETDATE()
Group By department
Order By tenure;

-- How many employees work remotely for each department ?

Select location,
count(location) As location_count
From [dbo].[HR Data]
Where new_termdate IS NULL
Group By location
Order By location_count

-- What's the distribution of employees across different states?

Select location_state,
Count(*) As locationstate_count
From [dbo].[HR Data]
Where new_termdate is NULL
Group By location_state
Order By locationstate_count DESC

--How are job titles disctributed in the company?

Select jobtitle,
count(*) as count
From [dbo].[HR Data]
where new_termdate is NULL
Group By jobtitle
Order by count DESC;

-- How have emplyoeehire counts varies over time?
--Calulate hire
--calculate terminate
--(hire-terminate)/hires perc hire chnage

Select hire_year,
hires,
terminations,
hires-terminations as net_change,
ROUND(CAST((hires-terminations) AS FLOAT)/hires, 2 ) *100 As percentage_hire_change
From 
(Select 
YEAR(hire_date) as hire_year,
Count(*) as hires,
SUM( CASE WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0 END) as terminations
From [dbo].[HR Data]
Group By YEAR(hire_date)) as subquery


