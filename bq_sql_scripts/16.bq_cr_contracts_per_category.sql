-- Contracts per category

CREATE TABLE IF NOT EXISTS `capture_milla.contracts_per_category` AS
SELECT 
  category,
  count(*) as contracts,
  count(distinct bytecode) as bytecodes,
  count(distinct creator_address) as creators,
  sum(case when (created_tx_status = 1 OR created_tx_status is null) then 1 else 0 end) AS contracts_status_1,
  sum(case when (created_tx_status = 0) then 1 else 0 end) as contracts_status_0
FROM `capture_milla.contracts` 
GROUP BY category 
ORDER BY 1