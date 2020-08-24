--too long runtime over 6 hours. Bigquery stopped.
--query needs to be optimized (various columns from con removed)
-- read  206.2 GB
-- took 3mins 13secs
CREATE TABLE IF NOT EXISTS `capture_milla.traces_of_cons` AS 
SELECT
 tr.value
 ,tr.trace_type
 ,tr.call_type
 ,tr.status
 ,tr.block_timestamp
 ,tr.block_number
 ,tr.trace_address
 ,rcon.category as recip_category
 ,scon.category as sendr_category
 ,rcon.opcode_md5 as recip_opcode_md5
 ,scon.opcode_md5 as sendr_opcode_md5
FROM
 `bigquery-public-data.crypto_ethereum.traces` tr
LEFT JOIN
 `capture_milla.contracts` rcon
 ON tr.to_address = rcon.address 
 LEFT JOIN
  `capture_milla.contracts` scon
 ON tr.from_address = scon.address 
WHERE
 DATE(tr.block_timestamp ) <= '2019-11-22'