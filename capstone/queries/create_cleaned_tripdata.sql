CREATE OR REPLACE TABLE `gwg-capstone-419217.cyclistic.cleaned-tripdata` AS (
 SELECT
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    ended_at - started_at AS trip_duration,
    DATE_DIFF(ended_at, started_at, SECOND) AS trip_duration_seconds,
    FORMAT_TIMESTAMP('%A', started_at) AS start_day_of_week,
    CASE 
      WHEN start_station_name IS NULL AND start_station_id IS NULL AND start_lat IS NOT NULL THEN REGEXP_REPLACE(CONCAT(ROUND(CAST(start_lat AS FLOAT64) * 1000, 0),ROUND(CAST(start_lng AS FLOAT64) * 1000, 0)), r'[^0-9.]', '') 
      WHEN start_station_name IS NULL AND start_station_id IS NOT NULL THEN start_station_id
    ELSE  start_station_name 
    END AS  start_station_name,
    CASE
      WHEN start_station_id LIKE '%.0' THEN SUBSTR(start_station_id, 1, LENGTH(start_station_id) - 2)
      WHEN start_station_name IS NULL AND start_station_id IS NULL AND start_lat IS NOT NULL THEN REGEXP_REPLACE(CONCAT(ROUND(CAST(start_lat AS FLOAT64) * 1000, 0),ROUND(CAST(start_lng AS FLOAT64) * 1000 ,0)), r'[^0-9.]', '')
      WHEN start_station_name IS NOT NULL AND start_station_id IS NULL THEN REGEXP_REPLACE(CONCAT(ROUND(CAST(start_lat AS FLOAT64) * 1000, 0),ROUND(CAST(start_lng AS FLOAT64) * 1000 ,0)), r'[^0-9.]', '')
    ELSE start_station_id
    END AS  start_station_id,
    CASE 
      WHEN end_station_name IS NULL AND end_station_id IS NULL AND end_lat IS NOT NULL THEN REGEXP_REPLACE(CONCAT(ROUND(CAST(end_lat AS FLOAT64) * 1000, 0),ROUND(CAST(end_lng AS FLOAT64) * 1000, 0)), r'[^0-9.]', '') 
    ELSE end_station_name 
    END AS  end_station_name,
    CASE
      WHEN end_station_id LIKE '%.0' THEN SUBSTR(end_station_id, 1, LENGTH(end_station_id) - 2)
      WHEN end_station_name IS NULL AND end_station_id IS NULL AND end_lat IS NOT NULL THEN REGEXP_REPLACE(CONCAT(ROUND(CAST(end_lat AS FLOAT64) * 1000, 0),ROUND(CAST(end_lng AS FLOAT64) * 1000 ,0)), r'[^0-9.]', '')
      WHEN end_station_name IS NOT NULL AND end_station_id IS NULL THEN REGEXP_REPLACE(CONCAT(ROUND(CAST(end_lat AS FLOAT64) * 1000, 0),ROUND(CAST(end_lng AS FLOAT64) * 1000 ,0)), r'[^0-9.]', '')
    ELSE end_station_id
    END AS  end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual AS member_type
  FROM
    `gwg-capstone-419217.cyclistic.tripdata`
  ORDER BY
    started_at ASC 
)

----------------------------------------------------------------------------------------------------------------------------

-- Add in new station UUIDs

-- CREATE OR REPLACE TABLE `gwg-capstone-419217.cyclistic.cleaned-tripdata` AS (
--   SELECT
--         td.*,
--         s_start.uuid AS start_station_uuid,
--         s_end.uuid AS end_station_uuid
--     FROM
--         `gwg-capstone-419217.cyclistic.cleaned-tripdata` td
--         LEFT JOIN `gwg-capstone-419217.cyclistic.cleaned-stations` s_start ON s_start.station_name = td.start_station_name
--         LEFT JOIN `gwg-capstone-419217.cyclistic.cleaned-stations` s_end ON s_end.station_name = td.end_station_name
-- )