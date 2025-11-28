----- q1#Converting the Datefields NaturalTime
use project;
select * from projects;
SELECT
  COUNT(*) AS total_rows,
  MIN(created_at) AS min_created,
  MAX(created_at) AS max_created,
  MIN(CHAR_LENGTH(created_at)) AS min_len,
  MAX(CHAR_LENGTH(created_at)) AS max_len
FROM projects;
UPDATE projects
SET created_dt = FROM_UNIXTIME(CAST(created_at AS UNSIGNED)),
    launched_dt = FROM_UNIXTIME(CAST(launched_at AS UNSIGNED)),
    deadline_dt = FROM_UNIXTIME(CAST(deadline AS UNSIGNED))
where created_dt IS Not NULL;
SELECT ProjectID,created_at,created_dt,launched_at,launched_dt,deadline,deadline_dt
FROM projects;
select min(from_unixtime(created_at)) as min_date,
       max(from_unixtime(created_at))as max_date from projects;
---#q2
drop table calender;
 CREATE TABLE calendar (
  cal_date DATE PRIMARY KEY,
  year INT,
  monthno TINYINT,
  monthfullname VARCHAR(20),
  quarter VARCHAR(3),
  yearmonth VARCHAR(10),
  weekdayno TINYINT,
  weekdayname VARCHAR(15),
  financial_month VARCHAR(6),
  financial_quarter VARCHAR(6),
  is_weekend BOOLEAN
);
SET SESSION cte_max_recursion_depth = 500000;
     WITH RECURSIVE calender AS (
  SELECT DATE(MIN(created_dt)) AS d
  FROM projects
  UNION ALL
  SELECT DATE_ADD(d, INTERVAL 1 DAY)
  FROM calender
  WHERE d < (SELECT DATE(MAX(created_dt)) FROM projects)

)
SELECT *
FROM calender;
select Year(from_unixtime((created_at))) AS Year from projects;
select Month(from_unixtime((created_at))) AS MonthNo from projects;
select Monthname(from_unixtime((created_at))) AS MonthName from projects;
select concat('Q',Quarter(from_unixtime((created_at)))) AS Quarter from projects;
select Monthname(from_unixtime((created_at))) AS YearMonth from projects;
select dayofweek(from_unixtime((created_at))) AS DayofWeek from projects;
select dayname(from_unixtime((created_at))) AS Dayname from projects;
SELECT
    CASE 
        WHEN MONTH(FROM_UNIXTIME(created_at)) >= 4 
            THEN CONCAT('FM', MONTH(FROM_UNIXTIME(created_at)) - 3)
        ELSE CONCAT('FM', MONTH(FROM_UNIXTIME(created_at)) + 9)
    END AS FinancialMonth 
    
    from projects;
    select 
CASE 
        WHEN MONTH(FROM_UNIXTIME(created_at)) BETWEEN 4 AND 6 THEN 'FQ-1'
        WHEN MONTH(FROM_UNIXTIME(created_at)) BETWEEN 7 AND 9 THEN 'FQ-2'
        WHEN MONTH(FROM_UNIXTIME(created_at)) BETWEEN 10 AND 12 THEN 'FQ-3'
        ELSE 'FQ-4'
    END AS FinancialQuarter
FROM projects;
select * from calender;

----#q3
-- Step 1: Category dimension
DROP TABLE IF EXISTS dim_category;
CREATE TABLE dim_category AS
SELECT DISTINCT category_id
FROM projects; 
select* from dim_category;
-- Step 2: Location dimension
DROP TABLE IF EXISTS dim_location;
CREATE TABLE dim_location AS
SELECT DISTINCT location_id, country
FROM projects;
select * from dim_location;
-- Step 3: Fact table
DROP TABLE IF EXISTS fact_projects;
CREATE TABLE fact_projects AS
SELECT *
FROM projects;
SELECT * FROM fact_projects;

---#q5
-- Total Number of Projects based on Outcome
SELECT state, COUNT(*) AS total_projects
FROM projects
GROUP BY state
ORDER BY total_projects DESC;

-- Total Number of Projects Based on Locations --
SELECT country, COUNT(*) AS total_projects
FROM projects
GROUP BY country
ORDER BY total_projects DESC;

-- Total Number of Projects Based on Category --
SELECT p.name, COUNT(p.ProjectID) AS total_projects
FROM projects p
JOIN category c ON p.category_id = c.category_id
GROUP BY p.name
ORDER BY total_projects DESC;


-- -- Total Number of Projects By Year, Quarter & Month --
SELECT 
    YEAR(from_unixtime(created_at)) AS year,
    QUARTER(from_unixtime(created_at)) AS quarter,
    MONTHNAME(from_unixtime(created_at)) AS month,
    COUNT(*) AS total_projects
FROM 
    projects
GROUP BY 
    YEAR(from_unixtime(created_at)), 
    QUARTER(from_unixtime(created_at)), 
    MONTHNAME(from_unixtime(created_at))
ORDER BY 
    YEAR(from_unixtime(created_at)) DESC, 
    QUARTER(from_unixtime(created_at)), 
    MONTHNAME(from_unixtime(created_at));

---#q6
---#Total Number of Projects By Amount Raised-
SELECT 
    name AS project_name,
    state,
    (goal * static_usd_rate) AS amount_raised
FROM projects WHERE 
    state = 'successful'
    order by amount_raised desc;
    
-- Total Number of Successful Projects By Backers --
SELECT 
    name AS project_name,
    state,
    backers_count
FROM projects WHERE state = 'successful' ORDER BY backers_count DESC;

-- Average Number of Days for Successful Projects --
SELECT 
    state as project,
    avg(datediff(successful_at, created_dt)) AS avg_project_duration_days
FROM projects WHERE state = 'successful'
ORDER BY 
    avg_project_duration_days DESC;
    
    -- q7 Total Number of Successful Projects By Backers --
SELECT 
    name AS project_name,
    state,
    backers_count
FROM projects WHERE state = 'successful' ORDER BY backers_count DESC;

    
-- q8(1). Percentage of Successful Projects overall
SELECT 
    (COUNT(CASE WHEN state = 'successful' THEN 1 END) * 100.0 / COUNT(*)) 
    AS success_percentage
FROM 
    projects;
    
-- #q8(2)Percentage of successful projects by category

SELECT 
    p.name AS person_name,
    COUNT(p.ProjectID) AS total_projects,
    COUNT(CASE WHEN p.state = 'successful' THEN 1 END) AS successful_projects,
    (COUNT(CASE WHEN p.state = 'successful' THEN 1 END) * 100.0 / COUNT(p.ProjectID)) 
    AS success_percentage
FROM 
    projects p
JOIN 
    category c 
    ON c.category_id = p.category_id
GROUP BY 
    p.name
ORDER BY 
    success_percentage DESC;

-- q8(3) Percentage of Successful Projects by Goal Range --

SELECT 
    
    CASE 
        WHEN (goal * static_usd_rate) < 5000 THEN 'less than 5000'
        WHEN (goal * static_usd_rate) BETWEEN 5000 AND 20000 THEN '5000 to 20000'
        WHEN (goal * static_usd_rate) BETWEEN 20000 AND 50000 THEN '20000 to 50000'
        WHEN (goal * static_usd_rate) BETWEEN 50000 AND 100000 THEN '50000 to 100000'
        ELSE 'greater than 100000'
    END AS goal_range,
    COUNT(ProjectID) AS total_projects,
    COUNT(CASE WHEN state = 'successful' THEN 1 END) AS successful_projects,
    (COUNT(CASE WHEN state = 'successful' THEN 1 END) * 100.0 / COUNT(ProjectID)) 
    AS success_percentage
FROM 
    projects
GROUP BY 
    goal_range
ORDER BY 
    success_percentage DESC;


    



