REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM 
REM ------------------------------------------------------------------------
REM PURPOSE:
REM 
REM ------------------------------------------------------------------------

set pagesize    0
set feedback    off
set verify      off
set head        off

SELECT * 
FROM NLS_DATABASE_PARAMETERS 
WHERE PARAMETER='NLS_CHARACTERSET' 
;

exit
