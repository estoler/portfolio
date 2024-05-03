CREATE OR REPLACE TABLE `gwg-capstone-419217.cyclistic.cleaned_stations` AS(
  -- WITH FullList AS(
    WITH FixedFalse AS(
      WITH StationList AS (
        WITH StartStations AS (
          SELECT
            DISTINCT start_station_name,
            STRING_AGG(DISTINCT start_station_id, ', ' ORDER BY start_station_id) AS start_ids
          FROM
            `gwg-capstone-419217.cyclistic.cleaned-divvy-tripdata`
          GROUP BY 1 
        ),
          EndStations AS (
          SELECT
            DISTINCT end_station_name,
            STRING_AGG(DISTINCT end_station_id, ', 'ORDER BY end_station_id) AS end_ids
          FROM
            `gwg-capstone-419217.cyclistic.cleaned-divvy-tripdata`
          GROUP BY 1 
        )
        SELECT
          start_station_name,
          CASE
            WHEN start_station_name = "Bissell St & Armitage Ave - Charging" THEN "Bissell St & Armitage Ave - Charging, chargingstx1"
            WHEN start_station_name = "hubbard_test_lws" THEN "hubbard_test_lws"
            WHEN start_ids IS NULL AND end_ids IS NOT NULL THEN end_ids
          ELSE start_ids
          END AS combined_start_ids,
          CASE
            WHEN start_station_name = "WEST CHI-WATSON" THEN "DIVVY 001, DIVVY 001 - Warehouse test station"
            WHEN start_station_name = "Ashland Ave & 73rd St" THEN "679, 721"
            WHEN start_station_name = "Dodge Ave & Main St" THEN "625, E011"
            WHEN start_station_name = "hubbard_test_lws" THEN "hubbard_test_lws"
            WHEN end_ids IS NULL AND start_ids IS NOT NULL THEN start_ids
          ELSE end_ids
          END AS combined_end_ids
        FROM
          StartStations ss
        FULL OUTER JOIN
          EndStations es
        ON
          ss.start_station_name = es.end_station_name
      )
      SELECT
        *,
        CASE
          WHEN sl.combined_start_ids = sl.combined_end_ids THEN TRUE
        ELSE FALSE
      END AS validation
      FROM
        StationList sl
      ORDER BY 2
    )
    SELECT
      GENERATE_UUID() AS uuid,
      CASE
        WHEN start_station_name IS NULL THEN combined_start_ids
      ELSE
      start_station_name
    END AS station_name,
      combined_start_ids,
      combined_end_ids,
      CASE
        WHEN ff.combined_start_ids = ff.combined_end_ids THEN TRUE
      ELSE FALSE
    END AS validation
    FROM
      FixedFalse ff
    ORDER BY validation, station_name
  -- )
  -- SELECT
  --   DISTINCT validation,
  --   COUNT(*)
  -- FROM
  --   FullList AS fl
  -- GROUP BY 1
)