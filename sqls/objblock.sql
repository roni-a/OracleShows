SET echo OFF veri OFF feed OFF lines 150

SELECT a.inst_id, 
       a.session_id, 
			 b.serial#, 
			 b.status, 
			 a.oracle_username,
       a.os_user_name, 
			 a.process, 
			 c.name
FROM   sys.obj$ c, 
       gv$session b, 
			 gv$locked_object a
WHERE  a.session_id = b.sid
AND    c.obj#       = a.object_id
/
PROMPT
exit


select s.inst_id, substr(u.username,1,12) user_name, s.sql_text
from gv$sql s, gv$session u
where s.hash_value = u.sql_hash_value
and s.inst_id = u.inst_id
and lower(sql_text) not like '%from v$sql s, v$session u%'
and sid in (37, 41, 22);
