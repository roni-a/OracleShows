col stat			for a4          trunc	head Stat
col tablespace_name     	for a25         	head Tablespace
col percent             	for a7			head "% Free"
SELECT substr(d.status,0,3) stat , 
       d.tablespace_name, 
       '  '||round(f.bytes/a.bytes*100,0)||'%' percent
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
   AND round(f.bytes/a.bytes*100,0) < 5
UNION ALL
SELECT substr(d.status,0,3) stat, 
       d.tablespace_name,  
       '  '||round((1-NVL(t.bytes,0)/a.bytes)*100,0)||'%' percent
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
   AND round((1-NVL(t.bytes,0)/a.bytes)*100,0) < 5
/
