------------------------------------------------------------------------------
-- show81tsps.sql
--
-- This SQL Plus script lists freespace by tablespace
------------------------------------------------------------------------------

set linesize    96
set pages       100
set verify off
set feedback off

col stat			for a4          trunc	head Stat
col content			for a4          trunc	head Type
col tablespace_name     	for a25         	head Tablespace
col MB                 	 	for 99,999		head "Tot|(MB)"
col free                	for 99,999      	head "Free|(MB)"
col largest             	for 9,999,999 		head "Largest|Extent|(MB)"
col percent             	for a7			head "% Free"
col extent_management		for a4		trunc 	head "Ext.|Mng"
col pct_increase		for 99          	head "Pct |Inc."
col allocation_type 		for a4		trunc 	head "Allc|type"

define lowfree=&1

SELECT substr(d.status,0,3) stat , substr(d.contents,0,1) content, 
       d.tablespace_name, 
       NVL (a.bytes / 1024 / 1024, 1) MB,
       NVL (f.bytes / 1024 / 1024, 1) free,
       NVL (l.large / 1024 / 1024, 1) largest,
       '  '||round(f.bytes/a.bytes*100,0)||'%' percent,
       d.extent_management, d.allocation_type,
       d.pct_increase
  FROM sys.dba_tablespaces d,
       (SELECT   tablespace_name, SUM(bytes) bytes
            FROM dba_data_files
        GROUP BY tablespace_name) a,
       (SELECT   tablespace_name, SUM(bytes) bytes
            FROM dba_free_space
        GROUP BY tablespace_name) f,
       (SELECT   tablespace_name, MAX(bytes) large
            FROM dba_free_space
        GROUP BY tablespace_name) l
 WHERE d.tablespace_name = a.tablespace_name(+)
   AND d.tablespace_name = f.tablespace_name(+)
   AND d.tablespace_name = l.tablespace_name(+)
   AND NOT (    d.extent_management LIKE 'LOCAL'
	     	AND d.contents LIKE 'TEMPORARY'
           )
and round(f.bytes/a.bytes*100,0) < &lowfree
UNION ALL
SELECT substr(d.status,0,3) stat, substr(d.contents,0,1) content, 
       d.tablespace_name,  
       NVL (a.bytes / 1024 / 1024, 1) MB,
       NVL (NVL (t.bytes, 0), 1) / 1024 / 1024 free,
       NVL (l.large / 1024, 1) largest,
       '  '||round((NVL(t.bytes,0)/NVL(a.bytes,1))*100,0)||'%' percent, 
       d.extent_management, d.allocation_type,
       d.pct_increase
  FROM sys.dba_tablespaces d,
       (SELECT   tablespace_name, SUM(bytes) bytes
            FROM dba_temp_files
        GROUP BY tablespace_name) a,
       (SELECT   tablespace_name, SUM(bytes_cached) bytes
            FROM v$temp_extent_pool
        GROUP BY tablespace_name) t,
       (SELECT   tablespace_name, MAX(bytes_cached) large
            FROM v$temp_extent_pool
        GROUP BY tablespace_name) l
 WHERE d.tablespace_name = a.tablespace_name(+)
   AND d.tablespace_name = t.tablespace_name(+)
   AND d.tablespace_name = l.tablespace_name(+)
   AND d.extent_management LIKE 'LOCAL'
   AND d.contents LIKE 'TEMPORARY'
AND round((NVL(t.bytes,0)/NVL(a.bytes,1))*100,0) < &lowfree
/

prompt

exit

