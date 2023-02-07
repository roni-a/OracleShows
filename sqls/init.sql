REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ tables
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show nls parameters 
REM ------------------------------------------------------------------------

set linesize	125
set pages	100
set feedback    off
set verify 	off

col name	for a30 trunc
col value	for a85 

SELECT name, value
FROM v$parameter
ORDER BY name
;
prompt 

exit
