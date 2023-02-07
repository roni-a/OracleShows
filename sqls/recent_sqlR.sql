set echo off feed off veri off lines 150 pages 0
set long 1000000
set longchunksize 10000
col sql_text format a100 heading "Current SQL"

SELECT 
--        s.inst_id, 
--        s.sid, 
--        serial#, 
q.SQL_FULLTEXT
       -- ,q.sql_text sql_text
FROM   gv$session s
     , gv$sql q
WHERE  s.sql_address = q.address
-- and s.sid = q.sid
and s.inst_id = q.inst_id
AND    s.sql_hash_value + DECODE (SIGN(s.sql_hash_value), -1, POWER( 2, 32), 0) = q.hash_value
AND    s.sid=&1
AND    s.inst_id=&2
/
exit
