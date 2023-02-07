
rem -----------------------------------------------------------------------
rem Filename:   archdist.sql
rem Purpose:    Tabular display of redo-log archiving history (logs/hour)
rem             - Can only run from sqlplus
rem Author:     Frank Naude (frank@ibi.co.za)
rem -----------------------------------------------------------------------

set lines 120 pagesize 50000
set feedback off veri off echo off
set colsep ""

prompt
set termout off
-- def time="time"                    -- Oracle7
-- col time new_value time
-- select 'to_char(first_time,''DD/MM/YY HH24:MI:SS'')' time
-- from   dual
-- where  &&_O_RELEASE like '8%'      -- Oracle8
-- /

def time="to_char(first_time,'MM/DD/YY HH24:MI:SS')"

set termout on
col day head "Day  "

select * from (
select substr(&&time, 1, 5) day,
       to_char(sum(decode(substr(&&time,10,2),'00',1,0)),'999') "  00",
       to_char(sum(decode(substr(&&time,10,2),'01',1,0)),'999') "  01",
       to_char(sum(decode(substr(&&time,10,2),'02',1,0)),'999') "  02",
       to_char(sum(decode(substr(&&time,10,2),'03',1,0)),'999') "  03",
       to_char(sum(decode(substr(&&time,10,2),'04',1,0)),'999') "  04",
       to_char(sum(decode(substr(&&time,10,2),'05',1,0)),'999') "  05",
       to_char(sum(decode(substr(&&time,10,2),'06',1,0)),'999') "  06",
       to_char(sum(decode(substr(&&time,10,2),'07',1,0)),'999') "  07",
       to_char(sum(decode(substr(&&time,10,2),'08',1,0)),'999') "  08",
       to_char(sum(decode(substr(&&time,10,2),'09',1,0)),'999') "  09",
       to_char(sum(decode(substr(&&time,10,2),'10',1,0)),'999') "  10",
       to_char(sum(decode(substr(&&time,10,2),'11',1,0)),'999') "  11",
       to_char(sum(decode(substr(&&time,10,2),'12',1,0)),'999') "  12",
       to_char(sum(decode(substr(&&time,10,2),'13',1,0)),'999') "  13",
       to_char(sum(decode(substr(&&time,10,2),'14',1,0)),'999') "  14",
       to_char(sum(decode(substr(&&time,10,2),'15',1,0)),'999') "  15",
       to_char(sum(decode(substr(&&time,10,2),'16',1,0)),'999') "  16",
       to_char(sum(decode(substr(&&time,10,2),'17',1,0)),'999') "  17",
       to_char(sum(decode(substr(&&time,10,2),'18',1,0)),'999') "  18",
       to_char(sum(decode(substr(&&time,10,2),'19',1,0)),'999') "  19",
       to_char(sum(decode(substr(&&time,10,2),'20',1,0)),'999') "  20",
       to_char(sum(decode(substr(&&time,10,2),'21',1,0)),'999') "  21",
       to_char(sum(decode(substr(&&time,10,2),'22',1,0)),'999') "  22",
       to_char(sum(decode(substr(&&time,10,2),'23',1,0)),'999') "  23"
-- ,to_char(sum(decode(substr(&&time,1,2)||substr(&&time,3,2),substr(&&time,1,2)||substr(&&time,3,2),1,0)),'999') " Sum"
,to_char(sum(decode(substr(&&time,1,5),substr(&&time,1,5),1,0)),'999') " Sum"
from   sys.v_$log_history
group  by substr(&&time,1,5)
)
order by 1 desc
/
prompt

set colsep " "

exit;

