-- query takes much time to execute 5hr 8min
-- needs to be optimized(various columns removed)

--CREATE TABLE `capture_milla.transactions_of_cons` AS 
--SELECT
--  tr.*
--  ,con.*
--FROM
--  `capture_milla.transactions` tr
--JOIN
--  `capture_milla.contracts` con
--  ON tr.to_address = con.address 
--WHERE
--  DATE(tr.block_timestamp ) <= '2019-11-22'
