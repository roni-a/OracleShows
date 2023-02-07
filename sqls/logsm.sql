set head off
set echo off
set feedback off
set verify off

select member from v$logfile where GROUP#=&1
/
exit;

