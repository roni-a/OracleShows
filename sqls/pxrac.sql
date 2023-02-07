set pagesize 1000 lines 155 verify off feedb off
column parallel_queries                 head "Parallel|Queries"
column parallel_operations              head "Parallel|Operations"
column operations_serialized            head "Operations|Serialized"
column operations_not_downgraded        head "Operations NOT|Downgraded"
column operations_downgraded            head "Operations|Downgraded"
column downgrade_severity               for 99.9 	head "Downgraded|Severity"

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
            FROM gv$px_session
           WHERE DEGREE IS NOT NULL
        GROUP BY qcsid, server_group, server_set)
/

prompt
prompt

select qcsid "Query Coordinator", count(*) as "Slaves Count" from v$px_session group by qcsid;

prompt
prompt 
-- set lines 190 pages 66
         prompt QC=Query Coordinator    User 'lsof -p' on spid of QC to see actual traffic
	         prompt
	         col username for a26
	         col adop head 'Acttual|DOP' justify c
	         col rdop head 'Requested|DOP' for 9999999 justify c
	         col qcsid head 'QC Sid' for a7
	         col qcslave head 'QC or|Slave'
	         col server_set head 'Slave set' for a10
	         col inst_id for 9999 head 'Inst|id' justify l
	         col sid for a6
					break on qcsid skip 1
	            select
	              s.inst_id,
	              decode(px.qcinst_id,NULL,s.username,
	                    ' - '||lower(substr(s.program,length(s.program)-4,4) ) ) Username,
	              decode(px.qcinst_id,NULL, 'QC', '(Slave)') qcslave,
	              to_char( px.server_set) server_set,
	              to_char(s.sid) SID,
	              decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) qcsid ,
	              px.req_degree rdop ,
	             px.degree adop, p.spid
	            from
	             gv$px_session px, gv$session s, gv$process p
	            where
	             px.sid=s.sid (+) and
	              px.serial#=s.serial# and
	             px.inst_id = s.inst_id
	              and p.inst_id = s.inst_id
	             and p.addr=s.paddr
	           order by 6,3 desc,5, 1 desc
	         /

prompt
prompt 

column child_wait  format a20 
column parent_wait format a20 
column server_name format a4  heading 'Name'
column x_status    format a10 heading 'Status'
column schemaname  format a20 heading 'Schema'
column x_sid format 9990 heading 'Sid'
column x_pid format 9990 heading 'Pid'
column p_sid format 9990 heading 'Parent'
column osuser format A12 heading 'OS User'

break on p_sid skip 1

select 
		   x.server_name
     , x.status as x_status
     , x.pid as x_pid
     , x.sid as x_sid
     , w2.sid as p_sid
     , v.osuser osuser
     , v.schemaname
     , SUBSTR(w1.event,1,20) as child_wait
     , SUBSTR(w2.event,1,20) as parent_wait
from  gv$px_process x
    , gv$lock l
    , gv$session v
    , gv$session_wait w1
    , gv$session_wait w2
where x.sid <> l.sid(+)
-- and   to_number (substr(x.server_name,2,3)) = l.id2(+)
and   regexp_replace (x.server_name,'[A-Z]','') = l.id2(+)
and   x.sid = w1.sid(+)
and   l.sid = w2.sid(+)
and   x.sid = v.sid(+)
and   nvl(l.type,'PS') = 'PS'
and   w1.event NOT IN ('SQL*Net message from client','SQL*Net more data to client')
and   w2.event NOT IN ('SQL*Net message from client','SQL*Net more data to client')
order by 5,3,4,6,7,8,9,1,2
/
exit;
