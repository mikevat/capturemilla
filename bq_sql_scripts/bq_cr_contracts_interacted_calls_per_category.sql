CREATE TABLE
  `capture_milla.contracts_interacted_calls_per_category` AS
WITH
  traces_group_cons AS (
  SELECT
    to_address,
    sum(case when tr.call_type = 'call' then 1 else 0 end) as call,
    sum(case when tr.call_type = 'callcode' then 1 else 0 end) as callcode,
    sum(case when tr.call_type = 'delegatecall' then 1 else 0 end) as delegatecall,
    sum(case when tr.call_type = 'staticcall' then 1 else 0 end) as staticcall
  FROM
    `bigquery-public-data.crypto_ethereum.traces` tr
  WHERE
    tr.block_timestamp <= '2019-11-22'
  GROUP BY
    to_address )
SELECT
  cons.category,
  count(*) as total_no_of_contracts,
  sum(case when tc.call > 0 then 1 else 0 end) as interacted_call,
  sum(case when tc.callcode > 0 then 1 else 0 end) as interacted_callcode,
  sum(case when tc.delegatecall > 0 then 1 else 0 end) as interacted_delegatecall,
  sum(case when tc.staticcall > 0 then 1 else 0 end) as interacted_staticcall
FROM
  `capture_milla.contracts` cons
left join
  traces_group_cons tc
  on cons.address = tc.to_address 
group by
  cons.category