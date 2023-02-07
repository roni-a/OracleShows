set lines 200 pages 100 timin on echo off feed off veri off
col "Used(MB)"       for 9,999,999
col "ActualSize(MB)" for 9,999,999
col "MaxSize(MB)"    for 999,999,999,999
col "FreeSpace(MB)"  for 9,999,999
col "Max Free Space" for 999,999,999,999

select t.tablespace_name Tablespace
, substr(t.contents, 1, 1) Type
, trunc((d.tbs_size-nvl(s.free_space, 0))/1024/1024) "Used(MB)"
, trunc(d.tbs_size/1024/1024) "ActualSize(MB)"
, trunc(d.tbs_maxsize/1024/1024) "MaxSize(MB)"
, trunc(nvl(s.free_space, 0)/1024/1024) "FreeSpace(MB)"
, trunc((d.tbs_maxsize - d.tbs_size + nvl(s.free_space, 0))/1024/1024) "Max Free Space"
, decode(d.tbs_maxsize, 0, 0, trunc((d.tbs_size-nvl(s.free_space, 0))*100/d.tbs_maxsize)) "Perc %"
from
  ( select SUM(bytes) tbs_size,
           SUM(decode(sign(maxbytes - bytes), -1, bytes, maxbytes)) tbs_maxsize, tablespace_name tablespace
    from ( select nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name
    from dba_data_files
    union all
    select nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name
    from dba_temp_files
    )
    group by tablespace_name
    ) d,
    ( select SUM(bytes) free_space,
    tablespace_name tablespace
    from dba_free_space
    group by tablespace_name
    ) s,
    dba_tablespaces t
    where t.tablespace_name = d.tablespace(+) and
    t.tablespace_name = s.tablespace(+)
    order by 8
/
exit
