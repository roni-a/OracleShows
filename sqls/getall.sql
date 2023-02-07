PROMPT
SET VERIFY OFF
SET FEEDBACK OFF
SET PAGESIZE 1000
set linesize 100
col "Script Name" for a15
col "Option Comments" for a45
col "Option" for a17 truncate
break on "Script Name"


SELECT DISTINCT upper(script_name) "Script Name",
OPT "Option", OPTION_COMMENTS "Option Comments"
FROM   oracle_dict
WHERE script_name like lower('%&1%');
prompt 
exit
