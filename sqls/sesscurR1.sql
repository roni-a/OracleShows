set linesize    230 pages       100 feedback    off verify 	off

col sid         for 999 trunc
col serial#     for 99999 trunc 	head SER#
col user_name   for a16                 head "User Name"
col osuser      for a10 trunc		head "OS User"
col sql_text     			head "Sql Text"

-- SELECT distinct s.sid, serial#, s.inst_id, o.user_name, osuser
-- FROM gv$open_cursor o, gv$session s 
-- WHERE o.saddr = s.saddr
-- AND   s.sid = &1
-- AND s.inst_id = &2
-- ;
-- 
-- col saddress noprint
-- break on saddress skip 1 on saddress
-- 
-- SELECT s.sid, serial#, s.inst_id, o.user_name, osuser, t.sql_text, t.address saddress
-- FROM gv$open_cursor o, gv$session s, gv$sqltext t
-- WHERE o.saddr   = s.saddr
-- AND   o.address = t.address
-- AND   s.sid     = &1
-- AND s.inst_id = &2
-- AND t.PIECE = 0
-- ORDER BY t.address, t.piece
-- ;
-- prompt

set lines 230 pagesize 0 feedback off trimspool off verify off
clear columns
clear breaks

select s.sid, serial#, s.inst_id, o.user_name, osuser, rtrim(upper(t.sql_text)) 
from gv$open_cursor o, gv$session s, gv$sqltext t
where t.hash_value in (
  select sql_hash_value 
	from gv$session
  union
  select prev_hash_value 
	from gv$session
  )
AND o.saddr   = s.saddr
AND   o.address = t.address
AND t.PIECE = 0
exit


SELECT 
  distinct s.sid,
	s.serial#, 
	s.inst_id,
	substr(username,1,12) username,
 	substr(osuser,1,10) osuser, 
	process, 
	program, 
  TO_CHAR(LOGON_TIME,'DD/MM/YY_HH24:MI') logon
FROM gv$session s
WHERE s.sid > 7 
  AND status = 'ACTIVE'
  AND username like upper('&1')
ORDER BY 3,1,2
/

prompt

exit

