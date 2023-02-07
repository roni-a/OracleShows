set pagesize 50
set linesize 180
column event   for a25
column state   for a25
column sid     for 999
column p2      for 9999999
column wait for 9999999


SELECT sid,event,wait_time Wait,state,decode(s.event,'latch free',l.name,null) latchname 
FROM v$session_wait s,v$latchname l
WHERE event not like 'SQL*Net%'
  AND event not like 'rdbms%'
  AND event not like 'smon%'
  AND event not like 'pmon%'
  AND s.p2=l.latch#
ORDER BY wait_time, event
;
prompt
exit
