REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ 
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show sql cursor, for a given sid 
REM ------------------------------------------------------------------------

set linesize    130
set pages       100
set feedback    off
set verify 	off

col sid         for 999 trunc
col serial#     for 99999 trunc 	head SER#
col user_name   for a16                 head "User Name"
col osuser      for a10 trunc		head "OS User"
col sql_text     			head "Sql Text"

SELECT distinct s.sid, serial#, o.user_name, osuser
FROM v$open_cursor o, v$session s 
WHERE o.saddr = s.saddr
AND   s.sid = &1
;

col saddress noprint
break on saddress skip 1 on saddress

SELECT t.sql_text, t.address saddress
FROM v$open_cursor o, v$session s, v$sqltext t
WHERE o.saddr   = s.saddr
-- AND   o.HASH_VALUE = s.SQL_HASH_VALUE
AND   o.address = t.address
-- AND   o.HASH_VALUE = t.HASH_VALUE
AND   s.sid     = &1
ORDER BY t.address, t.piece
;
prompt

exit
col sql_text                            head "ALL Other SESSION SQL's"
SELECT t.sql_text, t.address saddress, t.piece
FROM v$open_cursor o, v$session s, v$sqltext t
WHERE o.saddr   = s.saddr
AND   o.address = t.address
AND   s.sid     = &1
MINUS
SELECT t.sql_text, t.address saddress,  t.piece
FROM v$open_cursor o, v$session s, v$sqltext t
WHERE o.saddr   = s.saddr
AND   o.HASH_VALUE = s.SQL_HASH_VALUE
AND   o.address = t.address
AND   o.HASH_VALUE = t.HASH_VALUE
AND   s.sid     = &1
ORDER BY t.address, t.piece
;
exit

