-- Create contracts table from traces

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

--Create contract temporary table from traces:
CREATE TABLE `capture_milla.tmp_contracts`
	PARTITION BY created_date
	CLUSTER BY created_tx_status, category, creator_address, address
AS
SELECT
	to_address AS address
	,output AS bytecode
	,CASE WHEN output IS NULL THEN NULL ELSE disassemble_bytecode(output) END AS opcode

	,from_address AS creator_address
	,block_timestamp AS created_timestamp
	,DATE(block_timestamp) AS created_date

	,status AS created_tx_status
	,transaction_hash AS created_tx_hash

	,block_number AS created_block_number
	,block_hash AS created_block_hash
	
	,-1 AS category

FROM
	`bigquery-public-data.crypto_ethereum.traces`
WHERE
	trace_type = 'create'
	AND DATE(block_timestamp) <= '2019-11-22'
;
-- Clean up contracts table from duplicate values

-- Duplicate values are there because a contract created contract can be 
-- destroyed and re-created keeping the same address hash.
-- Through this cleaning, only the creation in the latest block is kept.
-- If 2 (or more) transactions are on the same block, a random transaction is kept
DELETE `capture_milla.tmp_contracts`
WHERE NOT EXISTS
  (
  SELECT * FROM
  (
    SELECT row.* FROM (
    SELECT ARRAY_AGG(t ORDER BY t.created_block_number DESC LIMIT 1)[OFFSET(0)] AS row
    FROM `capture_milla.tmp_contracts`  AS t
    GROUP BY address
    )
  ) foo
  WHERE foo.address = `capture_milla.tmp_contracts`.address 
  AND foo.created_block_number = `capture_milla.tmp_contracts`.created_block_number 
  AND foo.created_tx_hash  = `capture_milla.tmp_contracts`.created_tx_hash 
)
;
CREATE TABLE `capture_milla.tmp_contracts0` AS SELECT * FROM `capture_milla.tmp_contracts`;

-- Add opcodes (and opcodes without parameters) as string and create final table
CREATE TABLE `capture_milla.contracts`
	PARTITION BY created_date
	CLUSTER BY created_tx_status, category, creator_address, address
AS
SELECT
  c.*
  ,addr_opcodes.opcode AS opcode_str
  ,addr_opcodes.opcode_wo_params AS opcode_str_wo_params
  ,md5(addr_opcodes.opcode_wo_params) AS opcode_md5
FROM
  `capture_milla.tmp_contracts` c
LEFT JOIN
  (
  SELECT
    contr.address,
    STRING_AGG(CONCAT(flat_opcode.name,' ',IFNULL(flat_opcode.pushData,''))) AS opcode,
	STRING_AGG(flat_opcode.name) AS opcode_wo_params
  FROM
    `capture_milla.tmp_contracts` contr
  CROSS JOIN UNNEST(contr.opcode) AS flat_opcode  
  GROUP BY
    contr.address
  ) AS addr_opcodes
  ON c.address = addr_opcodes.address
;
