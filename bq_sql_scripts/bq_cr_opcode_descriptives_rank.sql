CREATE TABLE
  `capture_milla.opcode_descriptives_rank` AS
SELECT
  RANK() OVER (ORDER BY n DESC, GENERATE_UUID() DESC) AS rank,
  n
FROM
  `capture_milla.opcode_descriptives`
ORDER BY
  rank