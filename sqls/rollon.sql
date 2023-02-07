set echo off
set feedback off
set head off

select 'alter rollback segment '||SEGMENT_NAME||' online;'||chr(10)||':' from dba_rollback_segs where TABLESPACE_NAME not like 'SYSTEM'
;

exit;
