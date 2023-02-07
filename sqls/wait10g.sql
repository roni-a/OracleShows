set lines 150 pages 200 echo off
col event for a39

select event,
       total_waits,
       round(100 * (total_waits / sum_waits),2) pct_waits,
       time_wait_sec,
       round(100 * (time_wait_sec / greatest(sum_time_waited,1)),2)
       pct_time_waited,
       total_timeouts,
       round(100 * (total_timeouts / greatest(sum_timeouts,1)),2) 
       pct_timeouts,
       average_wait_sec
from
(select event,
       total_waits,
       round((time_waited / 100),2) time_wait_sec,
       total_timeouts,
       round((average_wait / 100),2) average_wait_sec
from sys.v_$system_event
where event not in 
('lock element cleanup', 
 'pmon timer', 
 'rdbms ipc message',
 'rdbms ipc reply',
 'smon timer', 
 'SQL*Net message from client', 
 'SQL*Net break/reset to client',
 'SQL*Net message to client',
 'SQL*Net more data from client',
 'dispatcher timer',
 'Null event',
 'parallel query dequeue wait',
 'parallel query idle wait - Slaves',
 'pipe get',
 'PL/SQL lock timer',
 'slave wait',
 'virtual circuit status',
 'WMON goes to sleep',
 'jobq slave wait',
 'Queue Monitor Wait',
 'wakeup time manager',
 'PX Idle Wait') AND 
 event not like 'DFS%' AND 
 event not like 'KXFX%'),
(select sum(total_waits) sum_waits,
        sum(total_timeouts) sum_timeouts,
        sum(round((time_waited / 100),2)) sum_time_waited
 from sys.v_$system_event
 where event not in 
 ('lock element cleanup', 
 'pmon timer', 
 'rdbms ipc message',
 'rdbms ipc reply',
 'smon timer', 
 'SQL*Net message from client', 
 'SQL*Net break/reset to client',
 'SQL*Net message to client',
 'SQL*Net more data from client',
 'dispatcher timer',
 'Null event',
 'parallel query dequeue wait',
 'parallel query idle wait - Slaves',
 'pipe get',
 'PL/SQL lock timer',
 'slave wait',
 'virtual circuit status',
 'WMON goes to sleep',
 'jobq slave wait',
 'Queue Monitor Wait',
 'wakeup time manager',
 'PX Idle Wait') AND 
 event not like 'DFS%' AND 
 event not like 'KXFX%')
order by 4 desc, 1 asc
/
exit

 
  
 
 
    
 
 
 

