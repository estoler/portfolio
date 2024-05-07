WITH tripdata AS (
  SELECT 
    FORMAT_TIMESTAMP('%Y-%m', started_at) AS year_month,
    member_type,
    rideable_type as bike_type,
    trip_duration_seconds,
    start_station_name,
    start_station_uuid
  FROM
    `gwg-capstone-419217.cyclistic.cleaned-divvy-tripdata` 
  WHERE
    trip_duration_seconds > 0
),
top_stations AS (
  SELECT 
    year_month,
    member_type,
    start_station_name AS station_name,
    start_station_uuid AS UUID,
    COUNT(*) AS total_rides
  FROM
    tripdata
  GROUP BY
    year_month,
    member_type,
    station_name,
    UUID
),
top_10_stations AS (
  SELECT 
    year_month,
    member_type,
    ARRAY_AGG(STRUCT(station_name, UUID, total_rides) ORDER BY total_rides DESC LIMIT 10) AS top_station
  FROM
    top_stations
  GROUP BY
    year_month,
    member_type
),
bike_usage AS (
  SELECT
    year_month,
    member_type,
    bike_type,
    COUNT(*) AS total_rides
  FROM
    tripdata
  GROUP BY
    year_month,
    member_type,
    bike_type
)
SELECT
  year_month,
  ARRAY<STRUCT<
      member_type STRING,
      total_rides INT64,
      max_duration STRING,
      avg_duration STRING,
      bike_usage ARRAY<STRUCT<
          bike_type STRING,
          total_rides INT64
        >>,
      top_stations ARRAY<STRUCT<
          station_name STRING,
          station_uuid STRING,
          total_rides INT64
        >>
  >>[
      STRUCT(
        'member' AS member_type,
        COUNTIF(member_type = 'member') AS total_rides,
        FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(MAX(IF(member_type = 'member', trip_duration_seconds, NULL)))) AS max_duration,
        FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(CAST(AVG(IF(member_type = 'member', trip_duration_seconds, NULL)) AS INT64))) AS avg_duration,
        (SELECT ARRAY_AGG(STRUCT(bike_type, total_rides)) FROM bike_usage WHERE year_month = td.year_month AND member_type = 'member') AS bike_usage,
        (SELECT top_station FROM top_10_stations WHERE year_month = td.year_month AND member_type = 'member') AS top_station
      ),
      STRUCT(
        'casual' AS member_type,
        COUNTIF(member_type = 'casual') AS total_rides,
        FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(MAX(IF(member_type = 'casual', trip_duration_seconds, NULL)))) AS max_duration,
        FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(CAST(AVG(IF(member_type = 'casual', trip_duration_seconds, NULL)) AS INT64))) AS avg_duration,
        (SELECT ARRAY_AGG(STRUCT(bike_type, total_rides)) FROM bike_usage WHERE year_month = td.year_month AND member_type = 'casual') AS bike_usage,
        (SELECT top_station FROM top_10_stations WHERE year_month = td.year_month AND member_type = 'casual') AS top_station
      )
  ] AS member_usage
FROM
    tripdata td
GROUP BY
    year_month
ORDER BY
    year_month

------------------------------------------------------------

-- SELECT
--   FORMAT_TIMESTAMP('%Y-%m', n.started_at) AS year_month,
--   ARRAY<STRUCT<
--       member_type STRING,
--       total_rides INT64,
--       max_duration STRING,
--       avg_duration STRING
--   >>[
--       STRUCT(
--           'member' AS member_type,
--           COUNTIF(n.member_type = 'member') AS total_rides,
--           FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(MAX(IF(n.member_type = 'member', n.trip_duration_seconds, NULL)))) AS max_duration,
--           FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(CAST(AVG(IF(n.member_type = 'member', n.trip_duration_seconds, NULL)) AS INT64))) AS avg_duration
--       ),
--       STRUCT(
--           'casual' AS member_type,
--           COUNTIF(n.member_type = 'casual') AS total_rides,
--           FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(MAX(IF(n.member_type = 'casual', n.trip_duration_seconds, NULL)))) AS max_duration,
--           FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(CAST(AVG(IF(n.member_type = 'casual', n.trip_duration_seconds, NULL)) AS INT64))) AS avg_duration
--       )
--   ] AS usage_details
-- FROM
--     `gwg-capstone-419217.cyclistic.cleaned-divvy-tripdata` td
-- WHERE
--     td.trip_duration_seconds > 0
-- GROUP BY
--     FORMAT_TIMESTAMP('%Y-%m', n.started_at)
-- ORDER BY
--     year_month