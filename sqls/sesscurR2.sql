set lines 230 pagesize 300 feedback off trimspool off verify off
clear columns
clear breaks
break on s.inst_id ON s.sid skip 1

select distinct(s.inst_id||' | '|| s.sid||' | '|| serial#||' | '|| o.user_name||' | '|| osuser||' | '|| rtrim(upper(t.sql_text)) ) AS "ACtive Connections"
from gv$open_cursor o, gv$session s, gv$sqltext t
where t.hash_value in (select sql_hash_value 
	                     from   gv$session
                       union
                       select prev_hash_value 
	                     from gv$session)
AND o.saddr   = s.saddr
AND   o.address = t.address
AND t.PIECE = 0
AND s.status = 'ACTIVE'
-- ORDER BY 3,1,2
ORDER BY 1
/
exit


