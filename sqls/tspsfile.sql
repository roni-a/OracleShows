REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on dba_ tables
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show tablespace files
REM ------------------------------------------------------------------------

set linesize	145
set pages       100
set feedback	off
set verify      off

col tablespace_name     for a32         head "TS Name"
col file_name		for a52		head "File Name"
col free_space   	for 999,999	head "Free MB"
col MB			for 999,999	head "Tot|(MB)"
col PCT			for a5		head "% |Free"

break on tablespace_name skip 1
compute sum of MB 	  on tablespace_name
compute sum of free_space on tablespace_name

SELECT 	ddf.tablespace_name, 
	file_name, 
	(sum(dfs.bytes)/1024/1024) free_space,
       	(ddf.bytes/1024/1024) MB 
,LPAD(ROUND(((sum(dfs.bytes)/1024/1024)/(ddf.bytes/1024/1024))*100,0),4,' ')||'%' PCT
FROM dba_data_files ddf, dba_free_space dfs
WHERE ddf.file_id=dfs.file_id (+)
AND   ddf.tablespace_name LIKE upper('%&1')
GROUP BY ddf.tablespace_name, file_name, ddf.bytes 
ORDER BY ddf.tablespace_name 
;
prompt

exit
