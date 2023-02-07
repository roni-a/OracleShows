PROMPT
SET VERIFY OFF
SET FEEDBACK OFF
SET PAGESIZE 1000
set linesize 100
col script_name for a20
col SCRIPT_COMMENTS for a50

SELECT DISTINCT upper(script_name) "SCRIPT_NAME",
SCRIPT_COMMENTS
FROM   oracle_dict
WHERE  script_name like lower('%&1%');
prompt 
exit
