REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ tables
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show datafile, control and redo list
REM ------------------------------------------------------------------------

set linesize	100
set pages       100
set feedback	off

col file_name	for a75		head 'Data File Name'
col name 	for a75		head 'Control/Temp File Name'
col member 	for a75		head 'Redo Log File Name'
col MB		for 9,999,999

SELECT file_name, bytes/1024/1024 MB
FROM dba_data_files
ORDER BY tablespace_name, file_id
;
SELECT member FROM v$logfile
;
SELECT name FROM v$controlfile
;
SELECT name FROM v$tempfile
;
prompt

exit
