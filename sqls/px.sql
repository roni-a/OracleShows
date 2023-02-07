set pagesize 100 lines 145 verify off feedb off
column parallel_queries                 head "Parallel|Queries"
column parallel_operations              head "Parallel|Operations"
column operations_serialized            head "Operations|Serialized"
column operations_not_downgraded        head "Operations NOT|Downgraded"
column operations_downgraded            head "Operations|Downgraded"
column downgrade_severity               head "Downgraded|Severity"

SELECT NVL (COUNT (DISTINCT qcsid), 0) parallel_queries,
       NVL (COUNT (*), 0) parallel_operations,
       NVL (SUM (DECODE (DEGREE, 1, 1, 0)), 0) operations_serialized,
       NVL (SUM (DECODE (DEGREE / req_degree, 1, 1, 0)),
            0
           ) operations_not_downgraded,
       NVL (SUM (DECODE (req_degree - DEGREE,
                         0, 0,
                         (DECODE (DEGREE, 1, 0, 1))
                        )
                ),
            0
           ) operations_downgraded,
         100
       - NVL (  SUM (DEGREE)
              * 100
              / DECODE (SUM (req_degree), 0, 1, SUM (req_degree)),
              0
             ) downgrade_severity
  FROM (SELECT   qcsid, server_group, server_set, MAX (DEGREE) DEGREE,
                 MIN (req_degree) req_degree
            FROM v$px_session
           WHERE DEGREE IS NOT NULL
        GROUP BY qcsid, server_group, server_set)
/

prompt
prompt

column child_wait  format a30
column parent_wait format a30
column server_name format a4  heading 'Name'
column x_status    format a10 heading 'Status'
column schemaname  format a10 heading 'Schema'
column x_sid format 9990 heading 'Sid'
column x_pid format 9990 heading 'Pid'
column p_sid format 9990 heading 'Parent'
column osuser format A12 heading 'OS User'

break on p_sid skip 1

select x.server_name
     , x.status as x_status
     , x.pid as x_pid
     , x.sid as x_sid
     , w2.sid as p_sid
     , v.osuser osuser
     , v.schemaname
     , w1.event as child_wait
     , w2.event as parent_wait
from  v$px_process x
    , v$lock l
    , v$session v
    , v$session_wait w1
    , v$session_wait w2
where x.sid <> l.sid(+)
and   to_number (substr(x.server_name,2)) = l.id2(+)
and   x.sid = w1.sid(+)
and   l.sid = w2.sid(+)
and   x.sid = v.sid(+)
and   nvl(l.type,'PS') = 'PS'
order by 1,2
/
exit;
