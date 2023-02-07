PROMPT
SET VERIFY OFF
SET FEEDBACK OFF
SET PAGESIZE 1000
set linesize 100
delete oracle_dict 
where script_name=lower('&1')
and opt=lower('&2');
commit;
exit
