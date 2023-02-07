set timin on lines 120 pages 600 verify off feed off echo off

DECLARE
   CURSOR cur_tbs IS
      SELECT
              fs.tablespace_name                                   TABLESPACE_NAME,
              df.totalspace                                        TABLESPACE_TOTAL_SIZE,
              (df.totalspace - fs.freespace)                       MB_USED,
              fs.freespace                                         MB_FREE,
              NVL(ROUND(100 * (fs.freespace / df.totalspace),0),0) PCT_FREE
      FROM    (SELECT tablespace_name, 
                      ROUND(SUM(bytes) / 1048576) TotalSpace
               FROM   dba_data_files 
               GROUP  BY tablespace_name ) df,
              (SELECT tablespace_name, 
                      ROUND(SUM(bytes) / 1048576) FreeSpace
               FROM   dba_free_space 
               GROUP  BY tablespace_name ) fs
      WHERE   df.tablespace_name = fs.tablespace_name(+)
      AND     fs.tablespace_name IN (SELECT tablespace_name
                                     FROM   dba_tablespaces
                                     WHERE  tablespace_name NOT LIKE ('TBS_DW_%')
                                     AND    tablespace_name NOT LIKE ('TBS_PHONE_%')
                                     AND    tablespace_name NOT IN ('SYSAUX','SYSTEM')
                                     AND    contents        NOT IN ('TEMPORARY','UNDO')
                                     AND    bigfile         = 'NO')
      ORDER   BY PCT_FREE;

BEGIN
   FOR tbs_rec IN cur_tbs
   LOOP
      DBMS_OUTPUT.PUT_LINE(RPAD(tbs_rec.TABLESPACE_NAME,30,' ')||'| '||LPAD(tbs_rec.TABLESPACE_TOTAL_SIZE,7,' ')||' | '||LPAD(tbs_rec.MB_USED,7,' ')||' | '||LPAD(tbs_rec.MB_FREE,7,' ')||' | '||LPAD(tbs_rec.PCT_FREE,5,' ')||'%');
   END LOOP;
END;
/

exit;

