/* 1. Unique Value & Distinct Enumeration
  * Objective: Identify all distinct entries across key categorical variables to understand data scope. */
SELECT 
	DISTINCT(weather_condition)
FROM traffic_accidents_workspace;

SELECT 
	DISTINCT(lighting_condition)
FROM traffic_accidents_workspace;

SELECT 
	DISTINCT(roadway_surface_cond)
FROM traffic_accidents_workspace;

SELECT 
	DISTINCT(first_crash_type)
FROM traffic_accidents_workspace;

SELECT 
	DISTINCT(crash_type)
FROM traffic_accidents_workspace;

/* 2. Data Aggregation & Column Totals
  * Objective: Calculate overall totals for numerical metrics to establish baseline volume and operational scale. */
SELECT 
	SUM(injuries_total)
FROM traffic_accidents_workspace;

SELECT 
	AVG(injuries_total)
FROM traffic_accidents_workspace;

SELECT 
	SUM(injuries_incapacitating)
FROM traffic_accidents_workspace;

/* 3. Volumetric & Time-Series Distribution
  * Objective: Analyze monthly record counts to observe temporal distribution and spot seasonal patterns. */
SELECT 
	crash_month, 
    COUNT(*) AS total_crashes
FROM traffic_accidents_workspace
GROUP BY crash_month
ORDER BY total_crashes DESC;

/* 4. Incident Analysis & Pattern Investigation
  * Objective: Answer the five analytical questions about crash occurences, factors and trend. */
  
-- Question 1. Which weather condition has the highest total injuries?
SELECT 
	weather_condition, 
    SUM(injuries_total) AS total_injuries
FROM traffic_accidents_workspace
GROUP BY weather_condition
ORDER BY total_injuries DESC
LIMIT 1;
-- Finding: "Clear" has the highest total injuries (64,288). This is a count, so it reflects 
-- that most crashes happen in clear weather. See Section 5 for the rate-base view.

-- Question 2. Which lighting condition has the highest and lowest incapicitating injuries?
WITH lighting_total AS (
	SELECT 
		lighting_condition, 
        SUM(injuries_incapacitating) AS incap_total
	FROM traffic_accidents_workspace
	GROUP BY lighting_condition)
SELECT 
	lighting_condition, 
    incap_total
FROM lighting_total 
WHERE incap_total = (
	SELECT 
		MAX(incap_total)
    FROM lighting_total)
    OR incap_total = (
    SELECT 
		MIN(incap_total)
    FROM lighting_total)
    ORDER BY incap_total DESC;
-- Finding: "Daylight" has the highest incapacitating injuries (4,557) and "Unknown" the lowest (60).
-- "Unknown" is a very small category, so the value is not meaningful.

-- Question 3. Which roadway surface condition has the highest number of crashes, 
-- and what is the most common primary contributory cause within that condition?
WITH roadway_crashes AS (
	SELECT 
		roadway_surface_cond,
		COUNT(*) AS count_surface
	FROM traffic_accidents_workspace
	GROUP BY roadway_surface_cond
    ORDER BY count_surface DESC
    LIMIT 1
    ),
prim_cause AS (
	SELECT 
        prim_contributory_cause,
		roadway_surface_cond,
        COUNT(*) AS prim_count
	FROM traffic_accidents_workspace
    WHERE roadway_surface_cond = (
		SELECT 
			roadway_surface_cond
        FROM roadway_crashes)
	GROUP BY prim_contributory_cause, roadway_surface_cond
    ORDER BY prim_count DESC)
SELECT  
	prim_contributory_cause, 
	roadway_surface_cond,
	prim_count
FROM prim_cause
WHERE prim_count = (
	SELECT MAX(prim_count)
    FROM prim_cause)  ;
-- Finding: "Dry" has the most crashes. Its most common primary contributory cause is "Unable to determine" (41,610 crashes),
-- which is a data quality gap rather than a real cause.

-- Question 4. What is the most common first crash type?
SELECT 
	first_crash_type, 
    COUNT(first_crash_type) AS count_type
FROM traffic_accidents_workspace
GROUP BY first_crash_type
ORDER BY count_type DESC
LIMIT 1;
-- Finding: "Turning" is the most common first crash type (64,150 crashes).

-- Question 5. Which months have the most and least occurences of the most common crash type?
WITH common_crash AS (
	SELECT 
		crash_type, 
		COUNT(*) AS type_count
	FROM traffic_accidents_workspace
	GROUP BY crash_type
    ORDER BY type_count DESC
    LIMIT 1
    ),
type_month AS (
	SELECT 
		crash_month, 
        crash_type,
		COUNT(*) AS monthly_count
	FROM traffic_accidents_workspace
	WHERE crash_type = (
		SELECT crash_type
        FROM common_crash)
	GROUP BY crash_month, crash_type
    ORDER BY monthly_count DESC)
SELECT 
	crash_month, 
    crash_type, 
    monthly_count
FROM type_month
WHERE monthly_count = (
	SELECT MAX(monthly_count)
    FROM type_month)  
    OR monthly_count = (
    SELECT MIN(monthly_count)
    FROM type_month);
-- Finding: The most common crash type is "NO INJURY / DRIVE AWAY". It occurs most in October (11,136)
--  and least in April (8,463).

/* 5. Rate-Based Follow-up Analysis
   Objective: Counts mostly reflect how many crashes happen in each condition. These queries compare
   rates per crash so conditions can be compared fairly. */
   
-- Follow-up A. Overall baseline injury rate.
SELECT
	COUNT(*) AS crashes,
    SUM(injuries_total) AS injuries,
    ROUND(SUM(injuries_total) / COUNT(*) * 100, 1)AS injuries_per_100_crashes
FROM traffic_accidents_workspace;
-- Finding: 38.3

-- Follow-up B. Injuries per 100 crashes by weather condition.
SELECT
	weather_condition,
	COUNT(*) AS crashes,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER () , 1)AS pct_of_all_crashes,
    SUM(injuries_total) AS injuries,
    ROUND(SUM(injuries_total) / COUNT(*) * 100, 1)AS injuries_per_100_crashes
FROM traffic_accidents_workspace
GROUP BY weather_condition
HAVING COUNT(*) >= 1000
ORDER BY injuries_per_100_crashes DESC;
-- Finding: Rain has the highest injury rate (41.2 injuries per 100 crashes). Clear weather has the most injuries
-- only because it has the most crashes (79.4% of all crashes).

-- Follow-up C. Incapacitating injuries per 1,000 crashes by lighting condition.
SELECT
	lighting_condition,
    COUNT(*) AS crashes,
    SUM(injuries_incapacitating) AS incapacitating_injuries,
    ROUND(SUM(injuries_incapacitating) / COUNT(*) * 1000, 1)AS incapacitating_per_1000_crashes
FROM traffic_accidents_workspace
GROUP BY lighting_condition
HAVING COUNT(*) >= 1000
ORDER BY incapacitating_per_1000_crashes DESC;
-- Finding: DARKNESS, LIGHTED ROAD has the highest injury rate (49.3 incapacitating injuries per 1000 crashes).

-- Follow-up D. Share of dry-road crashes with no determined cause.
SELECT
	COUNT(*) AS dry_road_crashes,
    SUM(CASE WHEN prim_contributory_cause = 'Unable to determine' THEN 1 ELSE 0 END) AS undetermined,
    ROUND(SUM(CASE WHEN prim_contributory_cause = 'Unable to determine' THEN 1 ELSE 0 END) * 100 / COUNT(*), 1) AS pct_undetermined
FROM traffic_accidents_workspace
WHERE roadway_surface_cond = 'Dry';
-- Finding: 26.7%





