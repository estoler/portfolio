SELECT
  ROW_NUMBER() OVER(ORDER BY started_at) AS index,
  ride_id,
  rideable_type,
  started_at,
  ended_at,
  -- trip_duration,
  trip_duration_seconds / 60 AS trip_duration_minutes,
  start_day_of_week,
  start_station_name,
  -- start_station_id,
  end_station_name,
  -- end_station_id,
  -- start_lat,
  -- start_lng,
  -- end_lat,
  -- end_lng,
  member_type,
  start_station_uuid,
  end_station_uuid
  -- *
  -- COUNT(ride_id) AS total_rides,
  -- COUNT(CASE
  --     WHEN member_type = "casual" THEN 1
  -- END
  --   ) AS casual_riders,
  -- COUNT(CASE
  --     WHEN member_type = "member" THEN 1
  -- END
  --   ) AS member_riders,
FROM
  `gwg-capstone-419217.cyclistic.cleaned-tripdata` TABLESAMPLE SYSTEM(1 PERCENT)
WHERE
  trip_duration_seconds > 0