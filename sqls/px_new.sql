set lines 230 pages 1000 veri off echo off 

col id 							for a10
col parentID 				for a10
col oracle_user 		for a20
col MACHINE 				for a20
col client_program 	for a20
col server_program 	for a20
col MODULE 					for a10
col ACTION					for a10
col RESOURCE_CONSUMER_GROUP for a10
col WAIT_DETAIL			for a70
col WAIT_NAME				for a15
col WAIT_PARAMETER  for a15

SELECT /*+ ORDERED USE_HASH(p i b t m) USE_HASH(SQL) */
      s.sid || '.' || s.serial# id,
          DECODE (px.qcsid, s.sid, NULL, px.qcsid)
       || DECODE (px.qcsid, s.sid, NULL, '.')
       || px.qcserial#
          parentID,
       s.sid sid,
       s.serial# serial,
       NVL (
          DECODE (TYPE,
                  'BACKGROUND', 'SYS (' || b.ksbdpnam || ')',
                  s.username),
          SUBSTR (p.program, INSTR (p.program, '(')))
          oracle_user,
       s.process client_pid,
       s.fixed_table_sequence fixed_table_sequence,
       s.status status,
       s.server server,
       s.machine machine,
       p.spid server_pid,
       NVL (s.osuser, '(' || b.ksbdpnam || ')') os_user,
       DECODE (
          px.qcsid,
          s.sid, SUM (
                    DECODE (
                       px.qcsid,
                       s.sid, 0,
                       NVL (i.block_gets, 0) + NVL (i.consistent_gets, 0)))
                 OVER (PARTITION BY px.qcsid),
          (NVL (i.block_gets, 0) + NVL (i.consistent_gets, 0)))
          logical_reads,
       s.program client_program,
       DECODE (
          px.qcsid,
          s.sid, SUM (DECODE (px.qcsid, s.sid, 0, NVL (i.physical_reads, 0)))
                    OVER (PARTITION BY px.qcsid),
          NVL (i.physical_reads, 0))
          physical_reads,
       NVL (t.ksusestv * 10, 0) cpu_usage,
       p.program server_program,
       s.logon_time logon_time,
       (NVL (i.block_changes, 0) + NVL (i.consistent_changes, 0))
          block_changes,
       NVL (i.consistent_gets, 0) consistent_gets,
       NVL (i.block_gets, 0) block_gets,
       s.username user_name,
       s.client_info client_info,
       s.module module,
       s.action action,
       s.resource_consumer_group resource_consumer_group,
       RAWTOHEX (s.sql_address) sql_address,
       s.sql_hash_value sql_hash_value,
       quest_soo_util.event_detail (s.EVENT,
                                    s.P1TEXT,
                                    s.P1,
                                    s.P2TEXT,
                                    s.P2,
                                    s.P3TEXT,
                                    s.P3,
                                    2)
          wait_detail,
       s.EVENT# wait_id,
       s.EVENT wait_name,
       DECODE (s.state,  'WAITING', 0,  'WAITED KNOWN TIME', 3,  4)
          wait_state,
       DECODE (s.state,
               'WAITING', TO_CHAR (s.seconds_in_wait),
               'WAITED KNOWN TIME', TO_CHAR (s.wait_time) * 10,
               s.state)
          wait_parameter,
       s.seconds_in_wait wait_seconds,
       s.wait_time * 10 wait_time,
       s.p1 wait_p1,
       s.p1text wait_p1text,
       s.p2 wait_p2,
       s.p2text wait_p2text,
       s.p3 wait_p3,
       s.p3text wait_p3text,
       px.server_set,
       px.server_group,
       px.degree,
       px.req_degree,
       px.qcinst_id,
       NULL
  FROM v$session s,
       v$sess_io i,
       v$process P,
       x$ksbdp b,
       x$ksusesta T,
       v$px_session px
 WHERE     (px.SID = s.SID AND px.serial# = s.serial#)
       AND p.addr = s.paddr
       AND i.SID = s.SID
       AND t.ksusenum = s.SID
       AND t.ksusestn = 12
       AND p.addr = b.ksbdppro(+)
       AND t.inst_id = USERENV ('INSTANCE')
       AND b.inst_id(+) = USERENV ('INSTANCE')
			AND rownum < 4
 ORDER BY 2,3
/
exit
