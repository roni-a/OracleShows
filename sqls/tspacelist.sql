set echo off
set feedback off
set head off

select TABLESPACE_NAME from dba_tablespaces where TABLESPACE_NAME not in ('TEMP','RBS','SYSTEM')
;

exit;
