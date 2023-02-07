REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ tables
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show waits status of events	
REM ------------------------------------------------------------------------

set linesize	96
set pagesize    9999
set feedback	off

select count(*), event from v$session_wait 
   where wait_time=0 group by event order by 1 desc
;
prompt

exit
