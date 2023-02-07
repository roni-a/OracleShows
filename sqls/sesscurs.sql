REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ 
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show sql cursors 
REM ------------------------------------------------------------------------

set linesize    150
set pages       100
set feedback    off
set verify 	    off

col username	for a&2                 head "User Name"
col sid         for 99999 trunc
col serial#     for 99999 trunc 	head SER#
col osuser      for a10 trunc		head "OS User"
col sql_text    for a150			head "Sql Text"

-- break on username on sid on serial# on osuser

prompt ==== &1 ======= &2 =======

SELECT username, 
       s.inst_id, 
       s.sid, 
       serial#, 
       osuser, 
       sql_text 
FROM   gv$open_cursor o, 
       gv$session s 
WHERE  o.inst_id   = s.inst_id
AND    o.saddr     = s.saddr
AND    username like upper('%&1%') 
ORDER  BY user_name, sid, serial#, osuser 
/

prompt

exit

