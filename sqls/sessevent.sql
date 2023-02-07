REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show sessions details
REM ------------------------------------------------------------------------

set linesize      96
set pages       100
set feedback    off
set verify          off

col SID                 for 999 trunc
col username            for a&3         head "User Name"
col event               for a30		head Event
col average_wait 	for 999999.999	head "Average     |Wait Seconds"
col tot_sec		for 999999999	head "Total     |seconds   "
col sid 		for 9999
col tot_waits		for 999999	head "Total  |waits  "
col total_timeouts 	for 999999	head "Total   |timeouts"
set lines 120

break on username on sid

SELECT sess.username, sess.sid, eve.EVENT,
       eve.time_waited/((case when (eve.total_waits - eve.total_timeouts) <= 0 then 1 else (eve.total_waits - eve.total_timeouts) end)*100) "average_wait",
        eve.total_waits - eve.total_timeouts tot_waits,
	eve.total_timeouts, eve.time_waited/100 tot_sec
FROM v$session sess, v$session_event eve
WHERE eve.sid = sess.sid
  AND sess.username like upper('&1')
  AND sess.sid like upper('&2')
  AND eve.total_waits <> 0
ORDER BY time_waited asc
;

prompt

exit


