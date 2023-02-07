REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on dba_ tables
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Create script for user creation
REM ------------------------------------------------------------------------

set verify off
set feedback off
set echo off
set pagesize 0
set termout off

spool &2\.sql

prompt spool &2\.log
prompt
SELECT 'create user '|| USERNAME || ' identified by values '''||PASSWORD||''''|| chr(10)||
       'default tablespace '|| DEFAULT_TABLESPACE || chr(10)|| 
       'temporary tablespace '||TEMPORARY_TABLESPACE || chr(10)||
       'quota unlimited on '|| DEFAULT_TABLESPACE ||
 ';'
FROM dba_users
WHERE username &1
  AND username not in ('SYSTEM','SYS','DBSNMP')
;
SELECT 'alter user ' || USERNAME || ' quota unlimited on ' || TABLESPACE_NAME ||
 ';'
from dba_ts_quotas
where  username &1
AND max_bytes = -1;

SELECT 'alter user ' || USERNAME || ' quota ' || MAX_BYTES || ' on ' || TABLESPACE_NAME || ';'
 from dba_ts_quotas
 where max_bytes != -1
 AND username &1;


prompt spool off
prompt exit

spool off

exit

