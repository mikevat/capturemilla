CREATE TABLE
  `capture_milla.contracts_wtrans` AS
WITH
  trans_of_cons AS (
  SELECT
    address,
    COUNT(*) AS n,
    SUM(value) AS total_value
  FROM
    `capture_milla.transactions_of_cons`
  GROUP BY
    address )
SELECT
  c.*,
  tc.n as total_trans,
  tc.total_value
FROM
  `capture_milla.contracts` c
LEFT JOIN
  trans_of_cons tc
ON
  c.address = tc.address