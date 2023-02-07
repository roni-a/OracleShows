set echo off
set feedback off
set head off
set verify off
select ') size '||(BYTES)/1024/1024||'M' from v$log where GROUP#=&1;

exit;
