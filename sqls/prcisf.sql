REM ------------------------------------------------------------------------
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show data files of precise on oravl01 
REM ------------------------------------------------------------------------

set linesize    80
set pagesize    9999
set feedback    off
set verify 	off

col name	for a60	 

SELECT name  
FROM v$datafile
where name like '/oravl01%precise%' or name like '/oravl01%PRECISE%'
;
prompt

exit

