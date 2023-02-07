REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ tables
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show Statistics on log buffer 
REM    
REM ------------------------------------------------------------------------

set linesize	96
set pages       100
set feedback	off

column log_block_size new_value LogBlockSize noprint
set verify off

select
  max(lebsz) log_block_size
from
  sys.x_$kccle
where
  inst_id = userenv('Instance')
/

column write_size new_value WriteSize noprint

select
  ceil(max(decode(name, 'redo blocks written', value))
      /max(decode(name, 'redo writes', value, 1)))
  * &LogBlockSize  write_size
from
  sys.v_$sysstat
/

column threshold  new_value ThesHold noprint 

select
  least(ceil(value/&LogBlockSize/3) * &LogBlockSize, 1024*1024)  threshold
from
  sys.v_$parameter
where
  name = 'log_buffer'
/


column sync_cost_ratio new_value SyncCostRatio noprint

select
  (sum(decode(name, 'redo synch time', value)) / sum(decode(name, 'redo synch writes', value)))
  / (sum(decode(name, 'redo write time', value)) / sum(decode(name, 'redo writes', value)))
    sync_cost_ratio
from
  v$sysstat
where
  name in ('redo synch writes', 'redo synch time', 'redo writes', 'redo write time')
/
set termout on
col "Average Log Write Size" for 999,999
col "Background Write Theshold" for 99,999,999

SELECT 	&WriteSize 	"Average Log Write Size", 
	&ThesHold 	"Background Write Theshold", 
	round(&SyncCostRatio,2) 	"Sync Cost Ratio",
	DECODE(ROUND(&SyncCostRatio),1,'OK','Increase log_buffer') "Evaluation"
FROM dual;

col logon       for 99.99       head "Requests |per Logon"
col users       for 99.99       head "Requests |per Trans"
col redo        for 9,999,999,999  head "Redo Space Requests"

SELECT r.value redo, (r.value/u.value) users, (r.value/l.value) logon,
       decode(sign((r.value/u.value)-1),1,'Increase log_buffer','OK') "Evaluation"
FROM v$sysstat l, v$sysstat u, v$sysstat r
WHERE l.name = 'logons cumulative'
AND u.name = 'user commits'
AND r.name='redo log space requests'
/

prompt

exit
