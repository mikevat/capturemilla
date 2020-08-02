WITH
  mycons AS (
  SELECT
    created_date as mc_created_date,
    COUNT(*) AS mc_n
  FROM
    `capture_milla.contracts`
  GROUP BY
    created_date ),
  theircons AS (
  SELECT
    DATE(block_timestamp) AS tc_created_date,
    COUNT(*) AS tc_n,
    SUM(CASE
        WHEN is_erc20 = FALSE AND is_erc721 = FALSE THEN 1
      ELSE
      0
    END
      ) AS tc_nf
  FROM
    `bigquery-public-data.crypto_ethereum.contracts`
  GROUP BY
    DATE(block_timestamp) 
    )
SELECT
  *,
  tc.tc_n - mc.mc_n AS diff_from_mine
FROM
  theircons tc
FULL JOIN
  mycons mc
ON
  mc.mc_created_date = tc.tc_created_date
  where  tc.tc_n - mc.mc_n <> 0