------------------------------------------------------------------------------
-- show81tsps.sql
--
-- This SQL Plus script lists freespace by tablespace
------------------------------------------------------------------------------

set linesize    96
set pages       100
set verify off
set feedback off

col stat			for a4          trunc	head "Stat|(1)"
col content			for a4          trunc	head "Type|(2)"
col tablespace_name     	for a25         	head "Tablespace|(3)-Default"
col MB                 	 	for 999,999		head "Tot(MB)|(4)"
col free                	for 99,999      	head "Free(MB)|(5)"
col largest             	for 9,999,999 		head "Largest   |Extent(K) (6)"
col percent             	for 999			head "% Free|(7)"
col dummy1			for a1			head " "
col extent_management		for a4		trunc 	head "Ext.|Mng"
col pct_increase		for 99          	head "Pct |Inc."
col allocation_type 		for a4		trunc 	head "Allc|type"

define orders=&1
define pct='%'

SELECT substr(d.status,0,3) stat , substr(d.contents,0,1) content, 
       d.tablespace_name, 
       NVL (a.bytes / 1024 / 1024, 1) MB,
       NVL (f.bytes / 1024 / 1024, 1) free,
       NVL (l.large / 1024, 1) largest,
       round(f.bytes/a.bytes*100,0) percent,'&pct' dummy1,
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
	     	AND d.contents LIKE 'TEMPORARY')
UNION ALL
SELECT substr(d.status,0,3) stat, substr(d.contents,0,1) content, 
       d.tablespace_name,  
       NVL (a.bytes / 1024 / 1024, 1) MB,
       NVL (NVL (t.bytes, 0), 1) / 1024 / 1024 free,
       NVL (l.large / 1024, 1) largest,
       round((NVL(t.bytes,0)/NVL(a.bytes,1))*100,0) percent,'&pct' dummy1, 
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
order by &orders
/

set pages 0
col totmb new_value xtotmb noprint
col totfree new_value xtotfree noprint
define Space1='Total                              '
define Space2='                 '

SELECT 	(NVL(a.bytes, 0) + NVL(d.bytes, 0))/1024/1024 totmb,
       	(NVL(a.bytes, 0) - NVL(t.bytes, 0) + NVL(f.bytes, 0))/1024/1024 totfree
  FROM 	(SELECT   SUM(bytes) bytes
            FROM dba_temp_files) a,
       	(SELECT   SUM(bytes_cached) bytes
            FROM v$temp_extent_pool) t,
       	(SELECT sum(bytes) bytes
	    FROM dba_data_files) d,
       	(SELECT   SUM(bytes) bytes
            FROM dba_free_space) f
;
prompt ---- ---- ------------------------- ------- -------- ------------- ---------

SELECT  '&&Space1', round(&xtotmb, 0) MB, round(&xtotfree, 0) free, '&&Space2',
        round((&xtotfree / &xtotmb) * 100, 0)||' %' percent
 from dual;

col realfree for 999,999
col realdata for 999,999

SELECT 'Real:                             ',
       (NVL(a.bytes, 0) + NVL(d.bytes, 0))/1024/1024 realdata,
       round((NVL(a.bytes, 0) - NVL(t.bytes, 0) + NVL(f.bytes, 0))/1024/1024) realfree,
       '   Without: SYSTEM, TMP, RBS''s, USERS, STATSPACK TableSpaces.'
  FROM  (SELECT   SUM(bytes) bytes
            FROM dba_temp_files 
		WHERE tablespace_name not in ('SYSTEM','TEMP','RBS1','RBS2','RBS3','RBS','IM_STATSPACK','USERS')) a,
        (SELECT   SUM(bytes_cached) bytes
            FROM v$temp_extent_pool
                WHERE tablespace_name not in ('SYSTEM','TEMP','RBS1','RBS2','RBS3','RBS','IM_STATSPACK','USERS')) t,
        (SELECT sum(bytes) bytes
            FROM dba_data_files 
                WHERE tablespace_name not in ('SYSTEM','TEMP','RBS1','RBS2','RBS3','RBS','IM_STATSPACK','USERS')) d,
        (SELECT   SUM(bytes) bytes
            FROM dba_free_space
                WHERE tablespace_name not in ('SYSTEM','TEMP','RBS1','RBS2','RBS3','RBS','IM_STATSPACK','USERS')) f
/


prompt

exit

