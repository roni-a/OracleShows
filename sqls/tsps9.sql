------------------------------------------------------------------------------
-- show9tsps.sql
--
-- This SQL Plus script lists freespace by tablespace
------------------------------------------------------------------------------

set linesize    130
set pages       100
set verify off
set feedback off

define _ord1=&1;
define _descAsc=&2;

col stat											for a4          trunc		head "Stat|(1)"
col content										for a4          trunc		head "Type|(2)"
col tablespace_name     			for a30        					head "Tablespace|(3)"
col MB                 	 			for 9,999,999						head "Tot(MB)|(4)"
col free                			for 999,999    					head "Free(MB)|(5)"
col largest             			for 9,999,999 					head "Largest   |Extent (M)"
col percent             			for 999									head "% Free|(7)"
col extent_management					for a4          trunc   head "Ext.|Mng"
col allocation_type						for a4          trunc   head "Allc|type"
col segment_space_management 	for a6					trunc 	head "Space|Mng"
col pct_increase              for 99                  head "Pct |Inc."

-- 100 - (NVL (t.bytes / a.bytes * 100, 0)) percent,


SELECT substr(d.status,0,3) stat , 
       substr(d.contents,0,1) content, 
       d.tablespace_name, 
       NVL (a.bytes / 1024 / 1024, 0) MB,
       NVL (f.bytes / 1024 / 1024, 0) free,
       NVL (l.large / 1024 / 1024, 0) largest,
       NVL (ROUND(f.bytes/a.bytes*100,0),0) percent,'%',
       d.extent_management, d.allocation_type,
       d.pct_increase, d.segment_space_management
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
UNION ALL
SELECT substr(d.status,0,3) stat, 
       substr(d.contents,0,1) content, 
       d.tablespace_name,  
       NVL (a.bytes / 1024 / 1024, 0) MB,
       NVL (a.bytes - NVL (t.bytes, 0), 0) / 1024 / 1024 free,
       NVL (l.large / 1024 / 1024, 0) largest,
       NVL(ROUND((1-NVL(t.bytes,0)/a.bytes)*100,0),0) percent,'%',
       d.extent_management, d.allocation_type,
       d.pct_increase, d.segment_space_management 
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
order by &_ord1 &_descAsc
/

set pages 0
col totmb new_value xtotmb for 999,999,999 noprint
col totfree new_value xtotfree for 999,999,999 noprint
define Space1='Total                                   '
define Space2='          '

SELECT  (NVL(a.bytes, 0) + NVL(d.bytes, 0))/1024/1024 totmb,
        (NVL(a.bytes, 0) - NVL(t.bytes, 0) + NVL(f.bytes, 0))/1024/1024 totfree
  FROM  (SELECT   SUM(bytes) bytes
            FROM dba_temp_files) a,
        (SELECT   SUM(bytes_cached) bytes
            FROM v$temp_extent_pool) t,
        (SELECT sum(bytes) bytes
            FROM dba_data_files) d,
        (SELECT   SUM(bytes) bytes
            FROM dba_free_space) f
;
prompt ---- ---- ------------------------------ ---------- -------- ---------- --------

SELECT  '&&Space1', round(&xtotmb, 0) MB, round(&xtotfree, 0) free, '&&Space2',
        round((&xtotfree / &xtotmb) * 100, 0) percent,'%'
 from dual;

prompt

exit

