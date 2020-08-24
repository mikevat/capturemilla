-- Create transactions :
-- added column recip_is_contract (recipient is contract)
-- added column transaction_status (for block < 4370000 receipt_status is null,
-- so status is in traces table when trace_address is null)
CREATE TABLE IF NOT EXISTS `capture-milla-259710.capture_milla.transactions`
AS
SELECT
  trans.hash,
  trans.nonce,
  trans.transaction_index,
  trans.from_address,
  trans.to_address,
  trans.value,
  trans.gas,
  trans.gas_price,
  trans.input,
  trans.receipt_cumulative_gas_used,
  trans.receipt_gas_used,
  trans.receipt_contract_address,
  trans.receipt_root,
  trans.receipt_status,
  CASE WHEN trans.receipt_status IS NOT NULL THEN trans.receipt_status ELSE trac.status END as transaction_status,
  trans.block_timestamp,
  trans.block_number,
  trans.block_hash,
  CASE WHEN contr.address IS NULL THEN 0 ELSE 1 END AS recip_is_contract,
  contr.category as contract_category
FROM
  `bigquery-public-data.crypto_ethereum.transactions` trans
LEFT JOIN
  `capture-milla-259710.capture_milla.contracts` contr
  ON
    trans.to_address = contr.address
LEFT JOIN
  `bigquery-public-data.crypto_ethereum.traces` trac
  ON trans.hash = trac.transaction_hash
  AND trac.trace_address IS NULL
WHERE
  DATE(trans.block_timestamp) <= '2019-11-22'
-- select * from `bigquery-public-data.crypto_ethereum.traces` where trace_address IS NULL and date(block_timestamp) = '2017-11-22'