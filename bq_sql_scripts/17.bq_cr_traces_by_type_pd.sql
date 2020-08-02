-- summarize trace types per day
CREATE TABLE `capture_milla.traces_by_type_pd` AS
SELECT
  DATE(block_timestamp) date,
  SUM(CASE WHEN trace_type = 'call' THEN 1 ELSE 0 END) AS trace_type_call,
  SUM(CASE WHEN trace_type = 'create' THEN 1 ELSE 0 END) AS trace_type_create,
  SUM(CASE WHEN trace_type = 'suicide' THEN 1 ELSE 0 END) AS trace_type_suicide,
  SUM(CASE WHEN trace_type = 'reward' THEN 1 ELSE 0 END) AS trace_type_reward,
  SUM(CASE WHEN trace_type = 'genesis' THEN 1 ELSE 0 END) AS trace_type_genesis,
  SUM(CASE WHEN trace_type = 'daofork' THEN 1 ELSE 0 END) AS trace_type_daofork
FROM
  `bigquery-public-data.crypto_ethereum.traces`
WHERE
	DATE(block_timestamp) <= '2019-11-22'
GROUP BY
DATE(block_timestamp)