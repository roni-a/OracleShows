set echo off feed off veri off lines 150 pages 500
col sql_text format a100 heading "Current SQL"

SELECT s.inst_id,
       s.sid,
       serial#,
       SUBSTR(q.sql_text,0,100) sql_text
FROM   gv$session s
     , gv$sql q
WHERE  s.sql_address = q.address
AND    s.sql_hash_value + DECODE (SIGN(s.sql_hash_value), -1, POWER( 2, 32), 0) = q.hash_value
AND    s.status = 'ACTIVE'
/
exit
