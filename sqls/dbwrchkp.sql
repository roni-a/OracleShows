REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ tables
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show Statistics on DBWR Checkpoints 
REM    
REM ------------------------------------------------------------------------

set linesize	96
set pages       100
set feedback	off

col logon	for 99.99	head "Checkpoints|per Logon  "
col users	for 99.99	head "Checkpoints|per Trans  "
-- col chkpnt	for 99,999,999	head "DBWR Timeouts"
col chkpnt	for 99,999,999	head "Background Timeouts"

SELECT c.value chkpnt, 
      (c.value/u.value) users, 
      (c.value/l.value) logon, 
       decode(sign((c.value/u.value)-1),1,'Increase log_checkpoint_interval','OK') "Evaluation"
FROM  v$sysstat l, 
      v$sysstat u, 
      v$sysstat c
WHERE LOWER(l.name) = 'logons cumulative'
AND   LOWER(u.name) = 'user commits'
-- AND   LOWER(c.name) = 'dbwr timeouts'
AND   LOWER(c.name) = 'background timeouts'
-- AND   LOWER(c.name) = 'dbwr lru scans'
;
prompt

exit
