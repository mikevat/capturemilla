CREATE TABLE
  `capture_milla.bytecode_descriptives` AS
SELECT
  con.bytecode,
  COUNT(*) AS n,
  COUNT(DISTINCT category) AS d_category,
  COUNT(DISTINCT creator_address) AS d_creators,
  MIN(con.created_timestamp) as min_created,
  MAX(con.created_timestamp) as max_created,
  TIMESTAMP_DIFF(MIN(con.created_timestamp),MAX(con.created_timestamp), MINUTE) AS created_timespan_minutes,
  timestamp_seconds(cast(AVG(UNIX_SECONDS(con.created_timestamp)) as int64)) as avg_created,
  cast(STDDEV(UNIX_SECONDS(con.created_timestamp)) as int64) as stddev_created_secs,
  min(category) as min_category,
  max(category) as max_category
FROM
  `capture_milla.contracts` con
GROUP BY
  con.bytecode