set pagesize 50
set line 132
#set echo off
col owner for a18
col TABS for 9999
col IND for 9999
col PACK for 9999
col VIEWS for 9999
col SYN for 9999
col SEQ for 9999

select owner,
count(decode(object_type,'TABLE',1)) TABS,
count(decode(object_type,'INDEX',1)) IND,
count(decode(object_type,'PACKAGE',1)) PACK,
count(decode(object_type,'VIEW',1)) VIEWS,
count(decode(object_type,'SYNONYM',1)) SYN,
count(decode(object_type,'SEQUENCE',1)) SEQ
from dba_objects
where owner not in ('SYS','SYSTEM','OUTLN','OPS\$ORACLE','SCOTT','DBSNMP','PRECI
SE')
group by owner;
exit



