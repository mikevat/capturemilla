-- FLAG contract category 8

MERGE `capture_milla.contracts` dest
USING (
  SELECT
    c1.address
    ,8 as category
  FROM
    `capture_milla.contracts` c1
  JOIN `capture_milla.contracts` cre
  ON (c1.creator_address = cre.address and cre.category = 7)
) sourc
ON
  sourc.address = dest.address
WHEN MATCHED THEN
  UPDATE SET
    dest.category = sourc.category