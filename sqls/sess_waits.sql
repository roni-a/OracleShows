set lines 200 pages 300 feedb off

col SID for 9999
col username for a15
col event for a28
col secwait for 9999 head "Sec.|Wait"
col p1text for a20 head "P1 Text"
col p2text for a10 head "P2 Text"
col p3text for a10 head "P3 Text"

SELECT  w.sid SID,
        s.username username,
        w.event event,
        w.seconds_in_wait secwait,
        w.p1text p1text,
        w.p1 p1_value,
        w.p2text p2text,
        w.p2 p2_value,
        w.p3text p3text,
        w.p3 p3_value
FROM    v$session_wait w, v$session s
WHERE   w.sid = s.sid
AND 	s.username NOT IN ('SYS','SYSTEM','OPS$ORACLE','SPOT')
AND	w.event NOT IN ('SQL*Net message from client')
ORDER   BY w.seconds_in_wait, username DESC
/

exit;
