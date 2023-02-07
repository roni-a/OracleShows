set lines 130 echo off verify off feedback off
column event format a29
column t0 format 999
column t1 format 999
column t2 format 999
column t3 format 999
column t4 format 999
column t5 format 999
column t6 format 999
column t7 format 999
column t8 format 999
column t9 format 999
column t10 format 999
column t11 format 999
column t12 format 999
column t13 format 999
column t14 format 999
column t15 format 999
column t16 format 999
column t17 format 999
column t18 format 999
column t19 format 999

prompt
prompt '                                               Top Wait Events for Inst_ID: 1                                                   '
prompt '                                               ==============================                                                   '

select /*+ ordered */
  substr(n.name, 1, 29)  event,
  t0,
  t1,
  t2,
  t3,
  t4,
  t5,
  t6,
  t7,
  t8,
  t9,
  t10,
  t11,
  t12,
  t13,
  t14,
  t15,
  t16,
  t17,
  t18,
  t19
from
  gv$event_name  n,
  (select event e0, inst_id, count(*)  t0 from gv$session_wait group by event, inst_id) sw1,
  (select event e1, inst_id, count(*)  t1 from gv$session_wait group by event, inst_id) sw2,
  (select event e2, inst_id, count(*)  t2 from gv$session_wait group by event, inst_id) sw3,
  (select event e3, inst_id,  count(*)  t3 from gv$session_wait group by event, inst_id) sw4,
  (select event e4, inst_id,  count(*)  t4 from gv$session_wait group by event, inst_id) sw5,
  (select event e5, inst_id,  count(*)  t5 from gv$session_wait group by event, inst_id) sw6,
  (select event e6, inst_id,  count(*)  t6 from gv$session_wait group by event, inst_id) sw7,
  (select event e7, inst_id,  count(*)  t7 from gv$session_wait group by event, inst_id) sw8,
  (select event e8, inst_id,  count(*)  t8 from gv$session_wait group by event, inst_id) sw9,
  (select event e9, inst_id,  count(*)  t9 from gv$session_wait group by event, inst_id) sw10,
  (select event e10, inst_id,  count(*)  t10 from gv$session_wait group by event, inst_id) sw11,
  (select event e11, inst_id,  count(*)  t11 from gv$session_wait group by event, inst_id) sw12,
  (select event e12, inst_id,  count(*)  t12 from gv$session_wait group by event, inst_id) sw13,
  (select event e13, inst_id,  count(*)  t13 from gv$session_wait group by event, inst_id) sw14,
  (select event e14, inst_id,  count(*)  t14 from gv$session_wait group by event, inst_id) sw15,
  (select event e15, inst_id,  count(*)  t15 from gv$session_wait group by event, inst_id) sw16,
  (select event e16, inst_id,  count(*)  t16 from gv$session_wait group by event, inst_id) sw17,
  (select event e17, inst_id,  count(*)  t17 from gv$session_wait group by event, inst_id) sw18,
  (select event e18, inst_id,  count(*)  t18 from gv$session_wait group by event, inst_id) sw19,
  (select event e19, inst_id,  count(*)  t19 from gv$session_wait group by event, inst_id) sw20
where
  n.inst_id = 1 AND
	sw1.inst_id = 1 AND
	sw2.inst_id = 1 AND
	sw3.inst_id = 1 AND
	sw4.inst_id = 1 AND
	sw5.inst_id = 1 AND
	sw6.inst_id = 1 AND
	sw7.inst_id = 1 AND
	sw8.inst_id = 1 AND
	sw9.inst_id = 1 AND
	sw10.inst_id = 1 AND
	sw11.inst_id = 1 AND
	sw12.inst_id = 1 AND
	sw13.inst_id = 1 AND
	sw14.inst_id = 1 AND
	sw15.inst_id = 1 AND
	sw16.inst_id = 1 AND
	sw17.inst_id = 1 AND
	sw18.inst_id = 1 AND
	sw19.inst_id = 1 AND
	sw20.inst_id = 1 AND
  n.WAIT_CLASS <> 'Idle' AND
  n.name != 'Null event' and
  n.name != 'rdbms ipc message' and
  n.name != 'pipe get' and
  n.name != 'virtual circuit status' and
  n.name not like '%timer%' and
  n.name not like 'SQL*Net message from %' and
  e0 (+) = n.name and
  e1 (+) = n.name and
  e2 (+) = n.name and
  e3 (+) = n.name and
  e4 (+) = n.name and
  e5 (+) = n.name and
  e6 (+) = n.name and
  e7 (+) = n.name and
  e8 (+) = n.name and
  e9 (+) = n.name and
  e10 (+) = n.name and
  e11 (+) = n.name and
  e12 (+) = n.name and
  e13 (+) = n.name and
  e14 (+) = n.name and
  e15 (+) = n.name and
  e16 (+) = n.name and
  e17 (+) = n.name and
  e18 (+) = n.name and
  e19 (+) = n.name and
  nvl(t0, 0) + nvl(t1, 0) + nvl(t2, 0) + nvl(t3, 0) + nvl(t4, 0) +
  nvl(t5, 0) + nvl(t6, 0) + nvl(t7, 0) + nvl(t8, 0) + nvl(t9, 0) +
  nvl(t10, 0) + nvl(t11, 0) + nvl(t12, 0) + nvl(t13, 0) + nvl(t14, 0) +
  nvl(t15, 0) + nvl(t16, 0) + nvl(t17, 0) + nvl(t18, 0) + nvl(t19, 0) > 0
order by
  nvl(t0, 0) + nvl(t1, 0) + nvl(t2, 0) + nvl(t3, 0) + nvl(t4, 0) +
  nvl(t5, 0) + nvl(t6, 0) + nvl(t7, 0) + nvl(t8, 0) + nvl(t9, 0) +
  nvl(t10, 0) + nvl(t11, 0) + nvl(t12, 0) + nvl(t13, 0) + nvl(t14, 0) +
  nvl(t15, 0) + nvl(t16, 0) + nvl(t17, 0) + nvl(t18, 0) + nvl(t19, 0)
/
prompt
prompt '                                               Top Wait Events for Inst_ID: 2                                                   '
prompt '                                               ==============================                                                   '

select /*+ ordered */
  substr(n.name, 1, 29)  event,
  t0,
  t1,
  t2,
  t3,
  t4,
  t5,
  t6,
  t7,
  t8,
  t9,
  t10,
  t11,
  t12,
  t13,
  t14,
  t15,
  t16,
  t17,
  t18,
  t19
from
  gv$event_name  n,
  (select event e0, inst_id, count(*)  t0 from gv$session_wait group by event, inst_id) sw1,
  (select event e1, inst_id, count(*)  t1 from gv$session_wait group by event, inst_id) sw2,
  (select event e2, inst_id, count(*)  t2 from gv$session_wait group by event, inst_id) sw3,
  (select event e3, inst_id,  count(*)  t3 from gv$session_wait group by event, inst_id) sw4,
  (select event e4, inst_id,  count(*)  t4 from gv$session_wait group by event, inst_id) sw5,
  (select event e5, inst_id,  count(*)  t5 from gv$session_wait group by event, inst_id) sw6,
  (select event e6, inst_id,  count(*)  t6 from gv$session_wait group by event, inst_id) sw7,
  (select event e7, inst_id,  count(*)  t7 from gv$session_wait group by event, inst_id) sw8,
  (select event e8, inst_id,  count(*)  t8 from gv$session_wait group by event, inst_id) sw9,
  (select event e9, inst_id,  count(*)  t9 from gv$session_wait group by event, inst_id) sw10,
  (select event e10, inst_id,  count(*)  t10 from gv$session_wait group by event, inst_id) sw11,
  (select event e11, inst_id,  count(*)  t11 from gv$session_wait group by event, inst_id) sw12,
  (select event e12, inst_id,  count(*)  t12 from gv$session_wait group by event, inst_id) sw13,
  (select event e13, inst_id,  count(*)  t13 from gv$session_wait group by event, inst_id) sw14,
  (select event e14, inst_id,  count(*)  t14 from gv$session_wait group by event, inst_id) sw15,
  (select event e15, inst_id,  count(*)  t15 from gv$session_wait group by event, inst_id) sw16,
  (select event e16, inst_id,  count(*)  t16 from gv$session_wait group by event, inst_id) sw17,
  (select event e17, inst_id,  count(*)  t17 from gv$session_wait group by event, inst_id) sw18,
  (select event e18, inst_id,  count(*)  t18 from gv$session_wait group by event, inst_id) sw19,
  (select event e19, inst_id,  count(*)  t19 from gv$session_wait group by event, inst_id) sw20
where
  n.inst_id = 2 AND
        sw1.inst_id = 2 AND
        sw2.inst_id = 2 AND
        sw3.inst_id = 2 AND
        sw4.inst_id = 2 AND
        sw5.inst_id = 2 AND
        sw6.inst_id = 2 AND
        sw7.inst_id = 2 AND
        sw8.inst_id = 2 AND
        sw9.inst_id = 2 AND
        sw10.inst_id = 2 AND
        sw11.inst_id = 2 AND
        sw12.inst_id = 2 AND
        sw13.inst_id = 2 AND
        sw14.inst_id = 2 AND
        sw15.inst_id = 2 AND
        sw16.inst_id = 2 AND
        sw17.inst_id = 2 AND
        sw18.inst_id = 2 AND
        sw19.inst_id = 2 AND
        sw20.inst_id = 2 AND
  n.WAIT_CLASS <> 'Idle' AND
  n.name != 'Null event' and
  n.name != 'rdbms ipc message' and
  n.name != 'pipe get' and
  n.name != 'virtual circuit status' and
  n.name not like '%timer%' and
  n.name not like 'SQL*Net message from %' and
  e0 (+) = n.name and
  e1 (+) = n.name and
  e2 (+) = n.name and
  e3 (+) = n.name and
  e4 (+) = n.name and
  e5 (+) = n.name and
  e6 (+) = n.name and
  e7 (+) = n.name and
  e8 (+) = n.name and
  e9 (+) = n.name and
  e10 (+) = n.name and
  e11 (+) = n.name and
  e12 (+) = n.name and
  e13 (+) = n.name and
  e14 (+) = n.name and
  e15 (+) = n.name and
  e16 (+) = n.name and
  e17 (+) = n.name and
  e18 (+) = n.name and
  e19 (+) = n.name and
  nvl(t0, 0) + nvl(t1, 0) + nvl(t2, 0) + nvl(t3, 0) + nvl(t4, 0) +
  nvl(t5, 0) + nvl(t6, 0) + nvl(t7, 0) + nvl(t8, 0) + nvl(t9, 0) +
  nvl(t10, 0) + nvl(t11, 0) + nvl(t12, 0) + nvl(t13, 0) + nvl(t14, 0) +
  nvl(t15, 0) + nvl(t16, 0) + nvl(t17, 0) + nvl(t18, 0) + nvl(t19, 0) > 0
order by
  nvl(t0, 0) + nvl(t1, 0) + nvl(t2, 0) + nvl(t3, 0) + nvl(t4, 0) +
  nvl(t5, 0) + nvl(t6, 0) + nvl(t7, 0) + nvl(t8, 0) + nvl(t9, 0) +
  nvl(t10, 0) + nvl(t11, 0) + nvl(t12, 0) + nvl(t13, 0) + nvl(t14, 0) +
  nvl(t15, 0) + nvl(t16, 0) + nvl(t17, 0) + nvl(t18, 0) + nvl(t19, 0)
/
prompt
exit;
