CREATE TABLE
  `capture_milla.contracts_interacted_per_category` AS
WITH
  trans_group_cons AS (
  SELECT
    to_address,
    SUM(transaction_status) AS status_1,
    COUNT(*) - SUM(transaction_status) AS status_0,
    COUNT(*) AS n
  FROM
    `capture_milla.trans_of_cons`
  WHERE
    recip_is_contract = 1
  GROUP BY
    to_address ),
  interacted_with AS (
  SELECT
    cons.address,
    cons.category,
    IFNULL(tc.n,0),CASE WHEN ifnull(tc.n, 0) > 0 THEN 1 ELSE 0 END AS interacted
  FROM
    `capture_milla.contracts` cons
  LEFT JOIN
    trans_group_cons tc
  ON
    cons.address = tc.to_address )
SELECT
  category,
  SUM(interacted) AS interacted
FROM
  interacted_with
GROUP BY
  category