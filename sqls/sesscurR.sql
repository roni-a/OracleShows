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

col sid         for 99999 trunc
col serial#     for 99999 trunc 	head SER#
col user_name   for a16                 head "User Name"
col osuser      for a10 trunc		head "OS User"
col sql_text     			head "Sql Text"

SELECT distinct s.sid, serial#, s.inst_id, o.user_name, osuser
FROM   gv$open_cursor o, 
       gv$session s 
WHERE  o.inst_id = s.inst_id 
AND    o.saddr = s.saddr
AND    s.sid = &1
AND    s.inst_id = &2
/

col saddress noprint
break on saddress skip 1 on saddress

SELECT t.sql_text, t.address saddress
FROM   gv$open_cursor o, 
       gv$session s, 
       gv$sqltext t
WHERE  o.saddr   = s.saddr
AND    o.address = t.address
AND    o.inst_id = s.inst_id
AND    o.inst_id = t.inst_id
AND    s.sid     = &1
AND    s.inst_id = &2
AND    t.PIECE  <= 10
ORDER  BY t.address, t.piece
/
prompt

exit

col sid		for 99999 trunc 
col INST_ID for 999 head "Ins|ID"
col serial#	for 99999 trunc	head SER#
col username	for a12 trunc	head "User Name" 
col osuser      for a10 trunc   head "OS User"
col process     for a13          head "Process"      
col program	for a14 trunc	head Program
col command     for a20                 head "Command"
col logon       for a15                 head "Logon Time"
col DEGREE			for 999			head "Prll|Dgre"
col REQ_DEGREE	for 999			head "Req|Prll"
col degra				for 999			head "Degrad|uation"

tti "Active Transactions|========================="

SELECT 
  distinct s.sid,
	s.serial#, 
	s.inst_id,
	substr(username,1,12) username,
       	substr(osuser,1,10) osuser, 
	process, 
	program, 
  TO_CHAR(LOGON_TIME,'DD/MM/YY_HH24:MI') logon
FROM gv$session s,
		 gv$px_session ps
WHERE s.sid > 7 
  AND s.sid = ps.sid
	AND s.inst_id = ps.inst_id
	AND s.serial# = ps.serial#
  AND status = 'ACTIVE'
  AND username like upper('%&1%')
ORDER BY 3,1,2
/

prompt

exit

