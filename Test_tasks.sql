CREATE DATABASE test_task;

CREATE TABLE a_data (
    date DATE,
    user_id VARCHAR(50),
    view_adverts INT
);

SELECT * FROM a_data;

-------------------------------------------
#1 7639
SELECT 
    COUNT(DISTINCT user_id) AS MAU
FROM
    a_data
WHERE
    date >= '2023-11-01'
        AND date < '2023-12-01';

---------------------------------------------
#2 560
SELECT 
    AVG(dau) AS avg_dau
FROM
    (SELECT 
        date, COUNT(DISTINCT user_id) AS dau
    FROM
        a_data
    WHERE
        date >= '2023-11-01'
            AND date < '2023-12-01'
    GROUP BY date) t;

------------------------------------------------------------
#3 26.6%
WITH first_visit AS (
    SELECT user_id
    FROM a_data
    WHERE date = '2023-11-01'
    GROUP BY user_id
),
returned AS (
    SELECT DISTINCT a.user_id
    FROM a_data a
    JOIN first_visit f ON a.user_id = f.user_id
    WHERE a.date = '2023-11-02'
)
SELECT 
    (SELECT COUNT(*) FROM returned) * 100 / (SELECT COUNT(*) FROM first_visit) AS retention_day1;
    
-----------------------------------------------------------------------------------------
#5 46.3%
WITH total_users AS (
    SELECT COUNT(DISTINCT user_id) AS total
    FROM a_data
    WHERE date >= '2023-11-01' AND date < '2023-12-01'
),
viewed_users AS (
    SELECT COUNT(DISTINCT user_id) AS viewed
    FROM a_data
    WHERE date >= '2023-11-01' AND date < '2023-12-01'
      AND view_adverts > 0
)
SELECT viewed * 100 / total AS conversion_rate
FROM total_users, viewed_users;
----------------------------------------------------------------
#6 2.9
SELECT 
    SUM(view_adverts) / COUNT(DISTINCT user_id) AS avg_ads_per_user
FROM
    a_data
WHERE
    date >= '2023-11-01'
        AND date < '2023-12-01';

-----------------------------------------------------------------
#7 35%
SELECT (1200 / 2000 - 500 / 2000) * 100 AS nps;

------------------------------------------------------------------
#9 156.4

CREATE TABLE listers (
    user_id INT,
    date DATE,
    cnt_adverts INT,
    age INT,
    cnt_contacts INT,
    revenue INT
);

SELECT * FROM listers;

SELECT SUM(revenue) / COUNT(DISTINCT user_id) AS avg_revenue_per_user
FROM listers;
--------------------------------------------------------------------------
#10 28
WITH unique_ages AS (
    SELECT DISTINCT user_id, age
    FROM listers
),
ordered AS (
    SELECT age,
           ROW_NUMBER() OVER (ORDER BY age) AS rn,
           COUNT(*) OVER () AS total
    FROM unique_ages
)
SELECT AVG(age) AS median_age
FROM ordered
WHERE rn IN (FLOOR((total + 1) / 2), CEIL((total + 1) / 2));
----------------------------------------------------------------------------------
