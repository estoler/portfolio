WITH NewUUIDs AS (
    SELECT
        td.*,
        s_start.uuid AS start_station_uuid,
        s_end.uuid AS end_station_uuid
    FROM
        `gwg-capstone-419217.cyclistic.cleaned-divvy-tripdata` td
        LEFT JOIN `gwg-capstone-419217.cyclistic.cleaned_stations` s_start ON s_start.station_name = td.start_station_name
        LEFT JOIN `gwg-capstone-419217.cyclistic.cleaned_stations` s_end ON s_end.station_name = td.end_station_name
)

SELECT
  FORMAT_TIMESTAMP('%Y-%m', n.started_at) AS year_month,
  ARRAY<STRUCT<
      member_type STRING,
      total_rides INT64,
      max_duration STRING,
      avg_duration STRING
  >>[
      STRUCT(
          'member' AS member_type,
          COUNTIF(n.member_type = 'member') AS total_rides,
          FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(MAX(IF(n.member_type = 'member', n.trip_duration_seconds, NULL)))) AS max_duration,
          FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(CAST(AVG(IF(n.member_type = 'member', n.trip_duration_seconds, NULL)) AS INT64))) AS avg_duration
      ),
      STRUCT(
          'casual' AS member_type,
          COUNTIF(n.member_type = 'casual') AS total_rides,
          FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(MAX(IF(n.member_type = 'casual', n.trip_duration_seconds, NULL)))) AS max_duration,
          FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(CAST(AVG(IF(n.member_type = 'casual', n.trip_duration_seconds, NULL)) AS INT64))) AS avg_duration
      )
  ] AS usage_details
FROM
    NewUUIDs n
WHERE
    n.trip_duration_seconds > 0
GROUP BY
    FORMAT_TIMESTAMP('%Y-%m', n.started_at)
ORDER BY
    year_month