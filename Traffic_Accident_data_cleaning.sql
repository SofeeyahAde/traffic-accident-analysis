-- Checked the total rows in the dataset
SELECT COUNT(*)
FROM traffic_accidents; 

-- Checked the entire dataset
SELECT *
FROM traffic_accidents;

-- Checked the unique crash date in the dataset
SELECT COUNT(DISTINCT crash_date)
FROM traffic_accidents;

-- Checked for duplicate
WITH duplicate_cte AS (
	SELECT *, 
	ROW_NUMBER() OVER( PARTITION BY crash_date, traffic_control_device, weather_condition, 
		lighting_condition, first_crash_type, trafficway_type, alignment, 
		roadway_surface_cond, road_defect, crash_type, intersection_related_i, damage, prim_contributory_cause, num_units, 
        most_severe_injury, injuries_total, injuries_fatal, injuries_incapacitating, injuries_non_incapacitating, 
        injuries_reported_not_evident, injuries_no_indication, crash_hour, crash_day_of_week, crash_month
        ) AS row_num
	FROM traffic_accidents
    )
SELECT COUNT(*)
FROM duplicate_cte
WHERE row_num > 1;
-- Finding: There are 31 duplicates

-- Created a staging table to do the data cleaning called traffic_accidents_workspace
CREATE TABLE `traffic_accidents_workspace` (
  `crash_date` text,
  `traffic_control_device` text,
  `weather_condition` text,
  `lighting_condition` text,
  `first_crash_type` text,
  `trafficway_type` text,
  `alignment` text,
  `roadway_surface_cond` text,
  `road_defect` text,
  `crash_type` text,
  `intersection_related_i` text,
  `damage` text,
  `prim_contributory_cause` text,
  `num_units` int DEFAULT NULL,
  `most_severe_injury` text,
  `injuries_total` double DEFAULT NULL,
  `injuries_fatal` double DEFAULT NULL,
  `injuries_incapacitating` double DEFAULT NULL,
  `injuries_non_incapacitating` double DEFAULT NULL,
  `injuries_reported_not_evident` double DEFAULT NULL,
  `injuries_no_indication` double DEFAULT NULL,
  `crash_hour` int DEFAULT NULL,
  `crash_day_of_week` int DEFAULT NULL,
  `crash_month` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Inserted data into the staging stable while adding column row_num to distinguish the duplicates
INSERT INTO traffic_accidents_workspace
	SELECT *, 
	ROW_NUMBER() OVER( 
		PARTITION BY crash_date, traffic_control_device, weather_condition, 
		lighting_condition, first_crash_type, trafficway_type, alignment, 
		roadway_surface_cond, road_defect, crash_type, intersection_related_i, damage, prim_contributory_cause, num_units, 
        most_severe_injury, injuries_total, injuries_fatal, injuries_incapacitating, injuries_non_incapacitating, 
        injuries_reported_not_evident, injuries_no_indication, crash_hour, crash_day_of_week, crash_month
        ) AS row_num
	FROM traffic_accidents;

SELECT *
FROM traffic_accidents_workspace;

-- Deleted the duplicates
DELETE 
FROM traffic_accidents_workspace
WHERE row_num > 1;

-- Checked the count of the rows after removing duplicates
SELECT COUNT(*)
FROM traffic_accidents_workspace;

SELECT *
FROM traffic_accidents_workspace
ORDER BY crash_date;

-- Checked the column crash_date while changing the data in it to standard datetime format
SELECT crash_date,
	CASE
    WHEN crash_date LIKE '%AM' OR crash_date LIKE '%PM' THEN
		CASE
			WHEN CAST(SUBSTRING_INDEX(crash_date, '/', 1) AS UNSIGNED) > 12
				THEN STR_TO_DATE(crash_date, '%d/%m/%Y %h:%i:%s %p')
			ELSE STR_TO_DATE(crash_date, '%m/%d/%Y %h:%i:%s %p')
		END 
	ELSE 
		CASE
			WHEN CAST(SUBSTRING_INDEX(crash_date, '/', 1) AS UNSIGNED) > 12
				THEN STR_TO_DATE(crash_date, '%d/%m/%Y %H:%i:%s')
			ELSE STR_TO_DATE(crash_date, '%m/%d/%Y %H:%i:%s')
		END 
	END AS cleaned_date
FROM traffic_accidents_workspace;

-- Updated the column crash_date while modifying the data in it to standard datetime format
UPDATE traffic_accidents_workspace
SET crash_date = CASE
	WHEN crash_date LIKE '%AM' OR crash_date LIKE '%PM' THEN
		CASE
			WHEN CAST(SUBSTRING_INDEX(crash_date, '/', 1) AS UNSIGNED) > 12
				THEN STR_TO_DATE(crash_date, '%d/%m/%Y %h:%i:%s %p')
			ELSE STR_TO_DATE(crash_date, '%m/%d/%Y %h:%i:%s %p')
		END 
	ELSE 
		CASE
			WHEN CAST(SUBSTRING_INDEX(crash_date, '/', 1) AS UNSIGNED) > 12
				THEN STR_TO_DATE(crash_date, '%d/%m/%Y %H:%i:%s')
			ELSE STR_TO_DATE(crash_date, '%m/%d/%Y %H:%i:%s')
		END 
	END;

-- Modified the data type of column crash_date to datetime
ALTER TABLE traffic_accidents_workspace
MODIFY COLUMN crash_date DATETIME;

-- Checked date range
SELECT MIN(crash_date), MAX(crash_date)
FROM traffic_accidents_workspace;

SELECT *
FROM traffic_accidents_workspace;

-- Checked the unique values in column weather_condition
SELECT DISTINCT weather_condition
FROM traffic_accidents_workspace;

-- Checked the unique values in column injuries_total
SELECT DISTINCT injuries_total
FROM traffic_accidents_workspace;

-- Created temp month column 
ALTER TABLE traffic_accidents_workspace
ADD temp_month VARCHAR(20);

-- Updated temp month column by changing values in crash month column to month name
UPDATE traffic_accidents_workspace
SET temp_month = CASE crash_month
	WHEN 1 THEN 'JANUARY' WHEN 2 THEN 'FEBRUARY' WHEN 3 THEN 'MARCH'
    WHEN 4 THEN 'APRIL' WHEN 5 THEN 'MAY' WHEN 6 THEN 'JUNE'
    WHEN 7 THEN 'JULY' WHEN 8 THEN 'AUGUST' WHEN 9 THEN 'SEPTEMBER'
    WHEN 10 THEN 'OCTOBER' WHEN 11 THEN 'NOVEMBER' WHEN 12 THEN 'DECEMBER'
END;

-- Dropped column crash month
ALTER TABLE traffic_accidents_workspace
DROP COLUMN crash_month;

-- Renamed column temp month to crash month
ALTER TABLE traffic_accidents_workspace
RENAME COLUMN temp_month TO crash_month;

-- Dropped column row num
ALTER TABLE traffic_accidents_workspace
DROP COLUMN row_num;