-- 9.2 sec elapsed, 2.2 GB processed
WITH c0_to_c5 AS (
SELECT
  c5.address          as c5_address         ,
  c5.creator_address  as c5_creator_address ,
  c4.address          as c4_address         ,
  c4.creator_address  as c4_creator_address ,
  c3.address          as c3_address         ,
  c3.creator_address  as c3_creator_address ,
  c2.address          as c2_address         ,
  c2.creator_address  as c2_creator_address ,
  c1.address          as c1_address         ,
  c1.creator_address  as c1_creator_address ,
  c0.address          as c0_address         ,
  c0.creator_address  as c0_creator_address      
FROM `capture-milla-259710.capture_milla.contracts` c5
LEFT JOIN `capture-milla-259710.capture_milla.contracts` c4
  ON c5.creator_address = c4.address
LEFT JOIN `capture-milla-259710.capture_milla.contracts` c3
  ON c4.creator_address = c3.address
LEFT JOIN `capture-milla-259710.capture_milla.contracts` c2
  ON c3.creator_address = c2.address
LEFT JOIN `capture-milla-259710.capture_milla.contracts` c1
  ON c2.creator_address = c1.address
LEFT JOIN `capture-milla-259710.capture_milla.contracts` c0
  ON c1.creator_address = c0.address
LEFT JOIN `capture-milla-259710.capture_milla.contracts` u
  ON c0.creator_address = u.address
WHERE 
  c5.category = 5
)
, contracts_of_analysis AS (
  select c0_address as contract from c0_to_c5
  union distinct
  select c1_address as contract from c0_to_c5
  union distinct
  select c2_address as contract from c0_to_c5
  union distinct
  select c3_address as contract from c0_to_c5
  union distinct
  select c4_address as contract from c0_to_c5
  union distinct
  select c5_address as contract from c0_to_c5
  union distinct
  select address as contract from `capture-milla-259710.capture_milla.contracts` where category > 5
  union distinct
  select c0_creator_address as user_address from c0_to_c5
)
SELECT
  coa.contract as address,
  con.category,
  con.creator_address,
  con.created_timestamp,
  con.created_date,
  con.created_block_number 
FROM contracts_of_analysis coa
LEFT JOIN `capture-milla-259710.capture_milla.contracts` con
  ON coa.contract = con.address