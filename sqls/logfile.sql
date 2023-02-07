spool log1.log
set echo off
set feedback off
set head off
set verify off
select distinct 'group '||group#||' (' from v$logfile where group#=&1;
select ''''||member||'''' from  v$logfile where group#=&1;
select ') size '||(BYTES)/1024/1024||'M' from v$log where GROUP#=&1;

exit;
spool off
