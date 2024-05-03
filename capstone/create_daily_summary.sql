WITH MonthDayMetrics AS(
  SELECT
    DISTINCT FORMAT_TIMESTAMP('%Y-%m', td.started_at) AS year_month,
    start_day_of_week,
    EXTRACT(dayofweek FROM td.started_at) AS num_start_day_of_week,
    COUNT(*) AS day_count,
    FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(MAX(trip_duration_seconds))) AS max_duration,
    FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(CAST(AVG(trip_duration_seconds) AS INT64))) AS avg_duration,
    member_type
  FROM
    `gwg-capstone-419217.cyclistic.cleaned-divvy-tripdata` td
  GROUP BY
    year_month,
    start_day_of_week,
    num_start_day_of_week,
    member_type
),
MaxRides AS (
  SELECT
    year_month,
    member_type,
    MAX(day_count) AS max_day_count
  FROM
    MonthDayMetrics
  GROUP BY
    year_month,
    member_type
),
MonthDayMetricsWithMaxRides AS (
  SELECT
    md.*,
    IF(md.day_count = mr.max_day_count, true, NULL) AS is_max_rides
  FROM
    MonthDayMetrics md
  JOIN
    MaxRides mr
  ON
    md.year_month = mr.year_month AND md.member_type = mr.member_type
),
TotalMetrics AS (
  SELECT
    DISTINCT FORMAT_TIMESTAMP('%Y-%m', td.started_at) AS year_month,
    'Total' AS start_day_of_week,
    0 AS num_start_day_of_week,
    COUNT(*) AS day_count,
    FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(MAX(trip_duration_seconds))) AS max_duration,
    FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(CAST(AVG(trip_duration_seconds) AS INT64))) AS avg_duration,
    member_type,
    CAST(NULL AS BOOL) AS is_max_rides
  FROM
    `gwg-capstone-419217.cyclistic.cleaned-divvy-tripdata` td
  GROUP BY
    year_month,
    member_type
)
SELECT
  year_month,
  member_type,
  ARRAY_AGG(STRUCT(is_max_rides, start_day_of_week, day_count, max_duration, avg_duration) 
            ORDER BY num_start_day_of_week) AS day_metrics
FROM
  (SELECT * FROM MonthDayMetricsWithMaxRides UNION ALL SELECT * FROM TotalMetrics)
GROUP BY
  year_month,
  member_type
ORDER BY
  year_month,
  member_type