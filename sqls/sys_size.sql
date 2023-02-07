set head off
select (bytes)/1024/1024 from v$datafile where name='&1' 
/
exit;

