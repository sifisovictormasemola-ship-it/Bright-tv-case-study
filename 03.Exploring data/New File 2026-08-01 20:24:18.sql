 With user_profiles AS (SELECT 
  userid,
  CASE
    WHEN province =' ' THEN 'uncategorized'
    WHEN province = 'none' THEN 'uncategorized'
    ELSE province
  END AS Region, 
  Age,
  CASE
    WHEN age = 0 THEN 'Infants'
    WHEN age BETWEEN 1 AND 12 THEN 'Kids'
    WHEN age BETWEEN 13 AND 19 THEN 'Teenager'
    WHEN age BETWEEN 20 AND 35 THEN 'Youth'
    WHEN age BETWEEN 36 AND 50 THEN 'Adult'
    WHEN age BETWEEN 51 AND 65 THEN 'Elder'
    WHEN age > 65 THEN 'Senior'
  END AS Age_groups,
   Case 
   When (email IS NOT NULL )OR(email= ' ') OR (email NOT IN  ('none')) Then 1
   ELSE 0
   END as Email_flag,
 
  CASE
    WHEN (`Social Media Handle` IS NOT NULL) OR (`Social Media Handle` != '  ') OR (`Social Media Handle` NOT IN ('none')) THEN 1
    ELSE 0
  END AS Sm_flag,
  
  CASE
    WHEN race IN ('other') THEN 'none'
    WHEN race = ' ' THEN 'none'
    ELSE race
  END AS Ethnicity,
  CASE
    WHEN Gender = ' ' THEN 'unknown'
    WHEN Gender ILIKE '%none%' THEN 'unknown'
    ELSE Gender
  END AS gender
FROM `workspace`.`default`.`bright_tv_user_profiles`
),
viewership AS(
  SELECT 
       COALESCE(UserID0, userid4,0) AS userid,       
       CASE       
         WHEN DAYNAME(RecordDate2) IN ('Sat', 'Sun') THEN 'Weekend'
         ELSE 'Weekday'         
       END AS day_classification,
       MONTHNAME(RecordDate2) AS Month_name,  
       DAYNAME(RecordDate2) AS Day_name,
       HOUR(RecordDate2) AS Hour_of_day,
       Date_format(RecordDate2, 'HH:mm:ss') AS Watch_time, 
      
       CASE
       WHEN Date_format(RecordDate2, 'hh:mm:ss') BETWEEN '00:00:00' AND '05:59:59' THEN 'Midnight'
       WHEN Date_format(RecordDate2, 'hh:mm:ss') BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
       WHEN Date_format(RecordDate2, 'hh:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
       WHEN Date_format(RecordDate2, 'hh:mm:ss') BETWEEN '17:00:00' AND '23:59:59' THEN 'Evening'
       End as Time_of_day,

ROUND(Hour(`Duration 2`) * 60 + minute(`Duration 2`) + second(`Duration 2`) / 60, 2) AS duration_minute,
       Date_format(`Duration 2`, 'HH:mm:ss') AS Duration,
       CASE
       WHEN duration <= '00:00:05' THEN 'Scrolling'
       WHEN duration BETWEEN '00:00:06' AND '00:30:00' THEN 'Low'
       WHEN duration BETWEEN '00:30:01' AND '01:00:00' THEN 'Medium'
       WHEN duration > '01:00:00' THEN 'High'
       End as Utilization,
       
       DATE_FORMAT(RecordDate2, 'yyyyMM') AS Month_id,
       DATE_FORMAT(RecordDate2, 'dd') AS Day_of_month,
       TO_DATE(RecordDate2) AS Watch_date,
       DAYOFWEEK(RecordDate2) AS Day_of_week,
       CASE
         WHEN Channel2 IN ('Sawsee', 'SawSee') THEN 'Sawsee'
         WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport','SuperSport Live Events','DSTV Events 1') THEN 'Live events'
         ELSE Channel2
       END AS TV_channnel
  FROM workspace.default.bright_tv_viewership
)
SELECT COUNT(B.userid) AS Subs,
day_classification,
Month_name,
Month_name,
Day_name,
Hour_of_day,
Watch_time,
Time_of_day,
Duration,
duration_minute,
Utilization,
Month_id,
Day_of_month,
Watch_date,
Day_of_week,
TV_channnel,
Region,
Age,
Age_groups,
Email_flag,
Sm_flag,
Ethnicity,
gender
FROM viewership AS A
Left join user_profiles AS B
ON A.userid = B.userid
GROUP BY 
day_classification,
Month_name,
Day_name,
Hour_of_day,
Watch_time,
Time_of_day,
Duration,
duration_minute,
Utilization,
Month_id,
Day_of_month,
Watch_date,
Day_of_week,
TV_channnel,
Region,
Age,
Age_groups,
Email_flag,
Sm_flag,
Ethnicity,
gender,