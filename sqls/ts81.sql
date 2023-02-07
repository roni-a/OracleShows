set lines 120 verify off
col TABLESPACE_NAME 		for a35 	head "Tablespace Name(1)"
col TABLESPACE_TOTAL_SIZE 	for 9,999,999 	head "Total|MB(2)"
col MB_USED 			for 9,999,999 	head "Used|MB(3)"
col MB_FREE 			for 9,999,999 	head "Free|MB(4)"
col PCT_FREE 					head "Free|%(5)"
col PRCNT_USED 			for a11 	head "Precent|Used(6)"

define _order=&2;

break on report
compute sum of TABLESPACE_TOTAL_SIZE on report
compute sum of MB_USED on report
compute sum of MB_FREE on report

SELECT
        fs.tablespace_name TABLESPACE_NAME,
        df.totalspace TABLESPACE_TOTAL_SIZE,
        (df.totalspace - fs.freespace) MB_USED,
        fs.freespace MB_FREE,
        round(100 * (fs.freespace / df.totalspace),0) PCT_FREE,
        RPAD(' '|| RPAD ('-' ,ROUND(10 * (fs.freespace / df.totalspace),0), '-'),11,chr(183)) PRCNT_USED
FROM    (SELECT tablespace_name, ROUND(SUM(bytes) / 1048576) TotalSpace
         FROM   dba_data_files GROUP BY tablespace_name ) df,
        (SELECT tablespace_name, ROUND(SUM(bytes) / 1048576) FreeSpace
         FROM dba_free_space GROUP BY tablespace_name ) fs
WHERE   df.tablespace_name = fs.tablespace_name(+)
union all
SELECT
        fs.tablespace_name TABLESPACE_NAME,
        df.totalspace TABLESPACE_TOTAL_SIZE,
        (df.totalspace - fs.freespace) MB_USED,
        fs.freespace MB_FREE,
        round(100 * (fs.freespace / df.totalspace),0) PCT_FREE,
        RPAD(' '|| RPAD ('-',ROUND(10 * (fs.freespace / df.totalspace),0), '-'),11,chr(183)) PRCNT_USED
FROM    (SELECT tablespace_name, ROUND(SUM(bytes) / 1048576) TotalSpace
         FROM   dba_temp_files GROUP BY tablespace_name ) df,
        (SELECT tablespace_name, ROUND(SUM(bytes_cached) / 1048576) FreeSpace
         FROM v$temp_extent_pool GROUP BY tablespace_name ) fs
WHERE   df.tablespace_name = fs.tablespace_name(+)
ORDER BY &1 &_order;

exit;

