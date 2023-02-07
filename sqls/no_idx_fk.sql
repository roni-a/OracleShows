set lines 120 echo off verify off 
col 	owner 	for a10	head 	"Owner"
col	cname	for a30	head	"Constraint Name"
col 	colname	for a30	head	"Column Name"
col	tname	for a25	head	"Table_name"

break on owner

SELECT  acc.owner owner,
 	acc.constraint_name cname,
 	acc.column_name colname,
	acc.table_name tname,
 	acc.position pos,
 	'No Index' Problem
FROM    dba_cons_columns acc, 
 	dba_constraints ac
WHERE   ac.constraint_name = acc.constraint_name
AND     ac.constraint_type = 'R'
AND     acc.owner not in ('SYS','SYSTEM')
AND     NOT EXISTS (
        SELECT  'TRUE' 
        FROM    dba_ind_columns b
        WHERE   b.table_owner = acc.owner
        AND     b.table_name = acc.table_name
        AND     b.column_name = acc.column_name
        AND     b.column_position = acc.position)
&1	AND 	acc.owner = UPPER('&2')
ORDER   BY acc.owner, acc.constraint_name, acc.column_name, acc.position;

exit;
