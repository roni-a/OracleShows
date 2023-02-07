REM ------------------------------------------------------------------------
REM PURPOSE:
REM    rebuild all user's partitioned indexes 
REM ------------------------------------------------------------------------

set verify off
set feedback off
set echo off
set pagesize 0
set termout off

spool &2\.sql

prompt spool &2\.log
prompt set echo on

SELECT 'alter index '||i.index_owner||'.'||i.index_name||' rebuild partition '||
i.PARTITION_NAME ||' storage (next '||
i.next_extent || ' pctincrease 0) tablespace &3 ; '
FROM dba_ind_partitions i
WHERE i.index_owner &1
AND i.tablespace_name=upper('&4') 
;

prompt spool off
prompt exit

spool off

exit
