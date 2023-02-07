set lines 150 pages 300 echo off
col username for a15
col event for a39
col total_waits head "Toatal|Waits"
col pct_of_total_waits head "PCT|Total|waits"
col time_wait_sec for 999999.99 head "Time|Wait|sec."
col total_timeouts head "Total|TimeOuts"
col average_wait_sec head "AVG|Wait|sec."
col max_wait_sec head "Max|Wait|sec."

SELECT sid,
       username,
       event,
       total_waits,
       100 * round((total_waits / sum_waits),2) pct_of_total_waits,
       time_wait_sec,
       total_timeouts,
       average_wait_sec,
       max_wait_sec
FROM
(SELECT a.event, 
       b.sid sid,
       decode (b.username,null,c.name,b.username) username,
       a.total_waits total_waits,
       round((a.time_waited / 100),2) time_wait_sec,
       a.total_timeouts total_timeouts,
       round((average_wait / 100),2)
       average_wait_sec,
       round((a.max_wait / 100),2) max_wait_sec
  FROM sys.v_$session_event a, 
       sys.v_$session b,
       sys.v_$bgprocess c,
       sys.v_$process d
 WHERE a.event NOT IN
          ('lock element cleanup',
          'pmon timer',
          'rdbms ipc message',
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
          'WMON goes to sleep'
          )
   AND a.event NOT LIKE 'DFS%'
   AND a.event NOT LIKE 'KXFX%'
   AND a.sid = b.sid
   AND d.addr = b.paddr 
   AND c.paddr (+) = b.paddr  
),
(select sum(total_waits) sum_waits
 FROM sys.v_$session_event a, 
       sys.v_$session b
 WHERE a.event NOT IN
          ('lock element cleanup',
          'pmon timer',
          'rdbms ipc message',
          'smon timer',
          'SQL*Net message from client',
          'SQL*Net break/reset to client',
          'SQL*Net more data from client',
          'SQL*Net message to client',
          'dispatcher timer',
          'Null event',
          'parallel query dequeue wait',
          'parallel query idle wait - Slaves',
          'pipe get',
          'PL/SQL lock timer',
          'slave wait',
          'virtual circuit status',
          'WMON goes to sleep'
          )
   AND a.event NOT LIKE 'DFS%'
   AND a.event NOT LIKE 'KXFX%'
   AND a.sid = b.sid)
order by 6 desc, 1 asc
/
exit

 
  
 
 
    
 
 
 

