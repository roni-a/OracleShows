rem Desc:    This simple script uses a 10-character bar graph to quickly show the amount of 
rem each datafile that is currently available. This script should allow a DBA to see 
rem datafile utilization from sqlplus without having to hassle with QUI tools. The x's 
rem represent used space in the datafile, and the -'s represent free space is the datafile. 
rem The MEGS column shows the size of the datafile and the USED column shows the amount of 
rem the datafile that is used. The AVAIL column does not show the total amount of available 
rem space, but the largest free extent. If the AVAIL column is much smaller then the MEGS - 
rem USED, then either the tablespace needs to be coalesced (use the command alter tablespace 
rem (tablespace name) coalesce;) or the extents are fragmented inside of the tablespace.  
rem Typical Use:    Small DB 
rem Os:    Any 
rem Remarks:    
 

COLUMN FILE_NM FORMAT A45
COLUMN TBS_NM FORMAT A20 TRUNCATE
COLUMN MEGS FORMAT 9999
COLUMN USED FORMAT 9999
COLUMN AVAIL FORMAT 99999
COLUMN PRCNT_USED FORMAT a11

SET linesize 130 pagesize 90 echo off verify off feedback    off

break on TBS_NM skip 1 on TBS_NM

SELECT 
  df.tablespace_name TBS_NM,
  df.file_name FILE_NM,
  df.bytes/1024/1024 MEGS,
  e.used_bytes/1024/1024 USED,
  f.free_bytes/1024/1024 AVAIL,
  RPAD(' '|| RPAD ('X',ROUND(e.used_bytes*10/df.bytes,0), 'X'),11,'-') PRCNT_USED
FROM dba_data_files df,
   (SELECT file_id,
      	   SUM(DECODE(bytes,NULL,0,bytes)) used_bytes
    FROM   dba_extents
    GROUP by file_id) E,
   (SELECT MAX(bytes) free_bytes,
           file_id
    FROM   dba_free_space
    GROUP BY file_id) f
WHERE e.file_id (+) = df.file_id
AND   df.file_id    = f.file_id (+)
ORDER BY df.tablespace_name, df.file_name
/

exit;
