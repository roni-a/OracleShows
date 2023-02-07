REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on dba_ tabbles
REM ------------------------------------------------------------------------
REM PURPOSE:
REM Analyze Users Indexes with the list chained rows option 
REM ------------------------------------------------------------------------

set linesize	80
set pages       0
set head 	off
set verify	off
set wrap	off
set termout	off
set echo	off
set feedback	off

spool &2 

SELECT 'analyze table &1' || '.'  || table_name || ' list chained rows;'
FROM dba_tables
WHERE owner='&1'
;

SELECT 'analyze index &1' || '.'  || index_name || ' list chained rows;' 
FROM dba_indexes
WHERE owner='&1'  
;

spool off
;
prompt

exit
