REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ and dba_* tables
REM ------------------------------------------------------------------------ 
REM PURPOSE:
REM    Show rollback segments contention
REM    The number of waits for any class should be less than 1% of the total 
REM    number of requests for data, else more rollback segments are needed.
REM ------------------------------------------------------------------------ 

set linesize    96
set pages       100
set feedback    off

REM SELECT class, count
REM FROM v$waitstat
REM WHERE class in ('system undo header', 'system undo block',
REM                 'undo header', 'undo block')
REM ;

SELECT sum(value)/100 "1% of total # of requests"
FROM v$sysstat
WHERE name in ('db block gets', 'consistent gets')
;

prompt

exit

