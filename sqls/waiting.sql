set echo off feed off veri off
COL wait FOR A50
SELECT  COL || ';' || wait_class WAIT, ROUND (time_secs, 2) time_secs1    FROM        (       SELECT 'CLASS' AS COL,  n.wait_class, sum(e.time_waited) / 1 time_secs          FROM v$system_event e, v$event_name n         WHERE n.NAME = e.event  AND n.wait_class <> 'Idle' AND e.time_waited > 0         group by 'CLASS', n.wait_class  UNION SELECT 'CLASS',  'CPU',   SUM (VALUE / 10000)          FROM v$sys_time_model         WHERE stat_name IN ('background cpu time', 'DB CPU')  UNION SELECT n.name, n.wait_class, e.time_waited          FROM v$system_event e, v$event_name n         WHERE n.NAME = e.event  AND n.wait_class <> 'Idle' AND e.time_waited > 0  UNION SELECT 'TIME', to_char(SYSDATE,'YYYYMMDD:HH24:MI:SS'), 0          FROM dual        ) order by 2,1
/
exit
