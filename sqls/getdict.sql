PROMPT
SET VERIFY OFF
SET FEEDBACK OFF
SET PAGESIZE 1000
col "Table" for a28
col "Comments"  for a50


SELECT a.table_name "Table",
       a.comments "Comments"
FROM   dict a
WHERE  a.table_name like Upper('%&1%');

PROMPT
exit
