set pages 300 lines 150 echo off veri off feed off timin on
col sid format 9999
col start_time format a5 heading "Start|time"
col elapsed format 9999 heading "Mins|past"
col min_remaining format 9999 heading "Mins|left"
col message format a81
select sid
, to_char(start_time,'hh24:mi') start_time
, elapsed_seconds/60 elapsed
, round(time_remaining/60,2) "min_remaining"
, message
from v$session_longops where time_remaining > 0
/

exit
