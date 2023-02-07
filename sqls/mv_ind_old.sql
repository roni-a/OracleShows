REM ------------------------------------------------------------------------
REM PURPOSE:
REM    rebuild all user's indexes
REM ------------------------------------------------------------------------

set verify off
set feedback off
set echo off
set pagesize 0
set termout off

spool &2\.sql

prompt spool &2\.log
prompt set echo on

SELECT 'alter index '||i.owner||'.'||i.index_name||' rebuild tablespace &3; '
FROM dba_indexes i, dba_segments s
WHERE i.owner=s.owner
  AND i.index_name=s.segment_name
  AND i.tablespace_name='&4' 
  AND i.owner &1
;

prompt spool off
prompt exit

spool off

exit
