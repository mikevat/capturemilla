-- FLAG contract category 0

MERGE `capture_milla.contracts` dest
USING (
  SELECT
    c1.address
    ,0 as category
  FROM
    `capture_milla.contracts` c1
  LEFT JOIN `capture_milla.contracts` cre
  ON c1.creator_address = cre.address 
  WHERE
  cre.address is null
) sourc
ON
  sourc.address = dest.address
WHEN MATCHED THEN
  UPDATE SET
    category = sourc.category