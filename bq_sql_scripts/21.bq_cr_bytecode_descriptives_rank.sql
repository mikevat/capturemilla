CREATE TABLE IF NOT EXISTS
  `capture_milla.bytecode_descriptives_rank` AS
SELECT
  RANK() OVER (ORDER BY n DESC, GENERATE_UUID() DESC) AS rank,
  n
FROM
  `capture_milla.bytecode_descriptives`
ORDER BY
  rank