-- sumarize transactions per day
CREATE TABLE IF NOT EXISTS `capture_milla.transactions_pd` AS
SELECT
  DATE(trans.block_timestamp) AS block_date,
  COUNT(*) as trans_count,
  SUM(CASE WHEN trans.transaction_status = 1 THEN 1 ELSE 0 END) AS successful_trans,
  SUM(CASE WHEN trans.transaction_status = 0 THEN 1 ELSE 0 END) AS failed_trans,
  SUM(CASE WHEN trans.transaction_status = 1 THEN trans.value ELSE 0 END) AS successful_value,
  SUM(CASE WHEN trans.transaction_status = 0 THEN trans.value ELSE 0 END) AS failed_value,
  SUM(trans.recip_is_contract) AS trans_to_contracts,
  MAX(ep.value) AS ether_price
FROM
  `capture_milla.transactions` trans
LEFT JOIN
  `capture_milla.ethereum_price` ep
  ON DATE(trans.block_timestamp) = ep.Date_UTC_ 
  
WHERE
	DATE(trans.block_timestamp) <= '2019-11-22'
GROUP BY
  DATE(trans.block_timestamp)