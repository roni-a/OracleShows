REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ tables
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show waits status
REM ------------------------------------------------------------------------

set linesize	96
set pagesize    9999
set feedback	off

SELECT * 
FROM v$waitstat 
;
prompt

exit
