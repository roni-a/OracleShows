PROMPT
SET VERIFY OFF
SET FEEDBACK OFF
SET PAGESIZE 1000
col "Comments" for a50
col "Table" for a28
col "Column" for a28

SELECT a.table_name "Table",
       a.comments "Comments"
FROM   dict a
WHERE  a.table_name = Upper('&1');

SELECT a.column_name "Column",
       a.comments "Comments"
FROM   dict_columns a
WHERE  a.table_name = Upper('&1');

exit
