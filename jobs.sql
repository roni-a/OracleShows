PROMPT Viewing scheduled dbms_jobs
-- 
-- When looking at what jobs have been scheduled, there is really only one view that you need to go to. The dba_jobs view contains all of the information you need, to see what has been scheduled, when they were last run, and if they are currently running. Use the following simple script to take a look. Bear with me on the sub-select, I will build on this query as we go on in the presentation.
-- 
-- scheduled_dbms_jobs.sql

set linesize 250
col log_user       for a10
col job            for 9999999  head 'Job'
col broken         for a1       head 'B'
col failures       for 99       head "fail"
col last_date      for a18      head 'Last|Date'
col this_date      for a18      head 'This|Date'
col next_date      for a18      head 'Next|Date'
col interval       for 9999.000 head 'Run|Interval'
col what           for a80

select j.log_user,
     j.job,
     j.broken,
     j.failures,
     j.last_date||':'||j.last_sec last_date,
     j.this_date||':'||j.this_sec this_date,
     j.next_date||':'||j.next_sec next_date,
     j.next_date - j.last_date interval,
     j.what
from (select dj.LOG_USER, dj.JOB, dj.BROKEN, dj.FAILURES, 
             dj.LAST_DATE, dj.LAST_SEC, dj.THIS_DATE, dj.THIS_SEC, 
             dj.NEXT_DATE, dj.NEXT_SEC, dj.INTERVAL, dj.WHAT
        from dba_jobs dj) j;

PROMPT What Jobs are Actually Running
-- 
-- A simple join to the dba_jobs_running view will give us a good handle on the scheduled jobs that are actually running at this time. This is done by a simple join through the job number. The new column of interest returned here is the sid which is the identifier of the process that is currently executing the job.

-- running_jobs.sql

set linesize 250
col sid            for 9999     head 'Session|ID'
col log_user       for a10
col job            for 9999999  head 'Job'
col broken         for a1       head 'B'
col failures       for 99       head "fail"
col last_date      for a18      head 'Last|Date'
col this_date      for a18      head 'This|Date'
col next_date      for a18      head 'Next|Date'
col interval       for 9999.000 head 'Run|Interval'
col what           for a60
select j.sid,
       j.log_user,
       j.job,
       j.broken,
       j.failures,
       j.last_date||':'||j.last_sec last_date,
       j.this_date||':'||j.this_sec this_date,
       j.next_date||':'||j.next_sec next_date,
       j.next_date - j.last_date interval,
       j.what
from (select djr.SID, 
             dj.LOG_USER, dj.JOB, dj.BROKEN, dj.FAILURES, 
             dj.LAST_DATE, dj.LAST_SEC, dj.THIS_DATE, dj.THIS_SEC, 
             dj.NEXT_DATE, dj.NEXT_SEC, dj.INTERVAL, dj.WHAT
        from dba_jobs dj, dba_jobs_running djr
       where dj.job = djr.job ) j;

PROMPT What Sessions are Running the Jobs
-- 
-- Now that we have determined which jobs are currently running, we need to find which Oracle session and operating system process is accessing them. This is done through first joining v$process to v$session by way of paddr and addr which is the address of the processs that owns the sessions, and then joining the results back to the jobs running through the sid value. The new columns returned in our query are spid which is the operating system process identifier and serial# which is the session serial number.

-- session_jobs.sql

set linesize 250
col sid            for 9999     head 'Session|ID'
col spid                        head 'O/S|Process|ID'
col serial#        for 9999999  head 'Session|Serial#'
col log_user       for a10
col job            for 9999999  head 'Job'
col broken         for a1       head 'B'
col failures       for 99       head "fail"
col last_date      for a18      head 'Last|Date'
col this_date      for a18      head 'This|Date'
col next_date      for a18      head 'Next|Date'
col interval       for 9999.000 head 'Run|Interval'
col what           for a60
select j.sid,
s.spid,
s.serial#,
       j.log_user,
       j.job,
       j.broken,
       j.failures,
       j.last_date||':'||j.last_sec last_date,
       j.this_date||':'||j.this_sec this_date,
       j.next_date||':'||j.next_sec next_date,
       j.next_date - j.last_date interval,
       j.what
from (select djr.SID, 
             dj.LOG_USER, dj.JOB, dj.BROKEN, dj.FAILURES, 
             dj.LAST_DATE, dj.LAST_SEC, dj.THIS_DATE, dj.THIS_SEC, 
             dj.NEXT_DATE, dj.NEXT_SEC, dj.INTERVAL, dj.WHAT
        from dba_jobs dj, dba_jobs_running djr
       where dj.job = djr.job ) j,
     (select p.spid, s.sid, s.serial#
          from v$process p, v$session s
         where p.addr  = s.paddr ) s
 where j.sid = s.sid;

exit
