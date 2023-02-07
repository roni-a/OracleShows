PROMPT
SET VERIFY OFF
SET FEEDBACK OFF
set pagesize 1000
col "Script Name" for a15
col "Option" for a17
col "Option Comments" for a45
break on "Script Name"


SELECT  DISTINCT upper(script_name) "Script Name",
OPT "Option",OPTION_COMMENTS "Option Comments"
FROM   oracle_dict
WHERE  OPTION_COMMENTS like lower('%&1%');
prompt 
exit
