REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ tables
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show datafile list
REM ------------------------------------------------------------------------

set linesize 140 pages 100 feedback off verify off

col fname 	for a65		head 'File Name'
col MB		for 9,999,999	head Size(MB)
col tsname 	for a35		head 'TableSpace Name'

define TableSpace_Name=&1

break on report
compute sum of MB on report

SELECT 	df.name fname, 
	df.bytes/1024/1024 MB, 
	ts.name tsname
FROM  	v$datafile df, 	
	v$tablespace ts
WHERE 	df.TS# = ts.TS#
AND  	ts.name LIKE upper('&&TableSpace_Name')
UNION
SELECT 	tf.name fname, 
	tf.bytes/1024/1024 MB, 
	ts.name tsname
FROM 	v$tempfile tf, 
	v$tablespace ts
WHERE 	tf.TS# = ts.TS#
AND  	ts.name LIKE upper('&&TableSpace_Name')
/
prompt

exit
