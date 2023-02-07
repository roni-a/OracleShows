set echo off
set term off
set pages 0
set feed off
set lines 400
spool  &2/compute.sql_&1
prompt break on report
select 'compute sum of '||tablespace_name||' on report '||chr(10)||'col '||tablespace_name||' for 999,999.99'
from dba_tablespaces
/
spool off

spool &2/usersize.sql_&1

prompt @&2/compute.sql_&1
prompt set echo off
prompt set  term on
prompt set pages 1000
prompt col tbs_total for 999,999.99
compute sum of tbs_total on report
prompt select
prompt sum(seg.blocks*ts.blocksize/1024/1024) tbs_total,
select 'sum(decode(ts.name,'''||tablespace_name||''', seg.blocks*ts.blocksize/1024/1024,0)) '||tablespace_name||','
 from (
 select tablespace_name from dba_tablespaces  where TABLESPACE_NAME !='SYSTEM' and CONTENTS='PERMANENT'
 minus
 select tablespace_name  from dba_rollback_segs 
);
-- where CONTENTS='PERMANENT' and TABLESPACE_NAME!='RBS';
prompt us.name Username
prompt FROM sys.ts$ ts,
prompt    sys.user$ us,
prompt      sys.seg$ seg
prompt WHERE seg.user# = us.user#
prompt and us.name not in ('SYS','SYSTEM')
prompt   AND ts.ts# = seg.ts#
prompt GROUP BY us.name
prompt /
prompt exit
spool off
set echo on
@ &2/usersize.sql_&1
