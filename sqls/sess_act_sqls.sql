set echo off feed off veri off timin on lines 200 pages 1000

col SQL_TEXT for a100

SELECT s.inst_id,
       s.sid,
       s.serial#,
       s.username,
       SUBSTR(t.sql_text,1,100) SQL_TEXT
FROM   gv$session s, 
       gv$sql t
WHERE  s.status  = 'ACTIVE'
AND    s.inst_id = t.inst_id
AND    s.sql_id  = t.sql_id
ORDER  BY sql_text, s.inst_id, s.sid
/
exit
