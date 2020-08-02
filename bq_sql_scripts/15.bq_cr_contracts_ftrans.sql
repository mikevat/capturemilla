-- Create contracts table from transactions:

-- Function to disassemble bytecode into opcode
CREATE TEMP FUNCTION
  disassemble_bytecode(bytecode string)
  RETURNS ARRAY<STRUCT<name string,
  fee int64,
  pushData string>>
  LANGUAGE js AS """
 return parseCode(bytecode);
 """ OPTIONS ( library="gs://ethereum-etl-bigquery/disassemble_bytecode.js" )
;

--Create temp table with contracts from transactions
CREATE TABLE `capture_milla.tmp_contracts_ftrans`
AS
SELECT
	receipt_contract_address AS address
	,input AS bytecode
	,CASE WHEN input IS NULL THEN NULL ELSE disassemble_bytecode(input) END AS opcode

	,from_address AS creator_address
	,block_timestamp AS created_timestamp
	,DATE(block_timestamp) AS created_date

	,transaction_status AS created_tx_status
	,`hash` AS created_tx_hash

	,block_number AS created_block_number
	,block_hash AS created_block_hash
	
	,0 AS category

FROM
	`capture_milla.transactions`
WHERE
	receipt_contract_address IS NOT NULL
	AND DATE(block_timestamp) <= '2019-11-22'
;

-- Add opcodes as string and create final table
CREATE TABLE `capture_milla.contracts_ftrans`
	PARTITION BY created_date
	CLUSTER BY created_tx_status, category, creator_address, address
AS
SELECT
  c.*
  ,addr_opcodes.opcode AS opcode_str
FROM
  `capture_milla.tmp_contracts_ftrans` c
JOIN
  (
  SELECT
    contr.address,
    STRING_AGG(CONCAT(flat_opcode.name,' ',IFNULL(flat_opcode.pushData,''))) AS opcode
  FROM
    `capture_milla.tmp_contracts_ftrans` contr
  CROSS JOIN UNNEST(contr.opcode) AS flat_opcode  
  GROUP BY
    contr.address
  ) AS addr_opcodes
  ON c.address = addr_opcodes.address
;
