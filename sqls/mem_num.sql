set head off

select distinct count(member) from v$logfile where GROUP#=1
/
exit;

