set echo off
set feedback off
set head off
set verify off

select EXTENT_MANAGEMENT, ALLOCATION_TYPE from dba_tablespaces where TABLESPACE_NAME='&1'
;

exit;
