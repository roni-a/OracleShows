-------------------------------------------------------------------------------
--
-- Script: response_time_breakdown.sql
-- Purpose: to report the components of foreground response time in % terms
-- For:  8.1.6
--
-- Copyright: (c) Ixora Pty Ltd
-- Author: Steve Adams
--
-------------------------------------------------------------------------------
set pages 500 lines 200 feedback off echo off

column major      format a8
column minor      format a13
column wait_event format a40 trunc
column seconds    format 999,999,999,999,999,999
column hours      format 9,999,999
-- column pct	  format 99.99
column pct        format a6 justify right

BREAK ON MAJOR SKIP 1 ON MINOR ON REPORT
COMPUTE SUM OF seconds ON REPORT

SELECT
  SUBSTR(n_major, 3)  major,
  SUBSTR(n_minor, 3)  minor,
  wait_event,
  ROUND(time/100)  seconds,
--  ROUND(time/100/3600/4)  hours,
  SUBSTR(TO_CHAR(100 * ratio_to_report(time) OVER (), '99.00'), 2) || '%'
  pct
--   TO_NUMBER(SUBSTR(TO_CHAR(100 * ratio_to_report(time) OVER (), '99.00'), 2)) pct,
--   '%'
FROM (SELECT /*+ ordered use_hash(b) */
          '1 CPU time'  n_major,
          DECODE (t.ksusdnam,
      'redo size', '2 reloads',
      'parse time cpu', '1 parsing',
      '3 execution')  n_minor,
      'n/a'  wait_event,
      DECODE (t.ksusdnam,
        'redo size', NVL(r.time, 0),
        'parse time cpu', t.ksusgstv - NVL(b.time, 0),
        t.ksusgstv - nvl(b.time, 0) - NVL(r.time, 0))  time
      FROM   sys.x$ksusgsta  t,
          (SELECT /*+ ordered use_nl(s) */  -- star query: few rows from d and b
          s.ksusestn,    -- statistic#
          SUM(s.ksusestv)  time   -- time used by backgrounds
             FROM   sys.x$ksusd  d,   -- statname
                sys.x$ksuse  b,   -- session
                sys.x$ksbdp  p,   -- background process
                sys.x$ksusesta  s   -- sesstat
             WHERE  d.ksusdnam IN ('parse time cpu',
                   'CPU used when call started')
             AND    b.ksspaown = p.ksbdppro
             AND    s.ksusestn = d.indx
             AND    s.indx = b.indx
             GROUP  BY s.ksusestn)  b,
          (SELECT /*+ no_merge */
          ksusgstv *    -- parse cpu time *
          kglstrld /    -- SQL AREA reloads /
          (1 + kglstget - kglstght)  -- SQL AREA misses
              time
             FROM   sys.x$kglst  k,
                sys.x$ksusgsta  g
             WHERE  k.indx = 0
             AND    g.ksusdnam = 'parse time cpu')  r
WHERE  t.ksusdnam IN ('redo size',            -- arbitrary: to get a row to replace
          'parse time cpu',         --   with the 'reload cpu time'
          'CPU used when call started')
AND    b.ksusestn (+) = t.indx
UNION  ALL
SELECT DECODE(n_minor,
       '1 normal I/O',      '2 disk I/O',
       '2 full scans',      '2 disk I/O',
       '3 direct I/O',      '2 disk I/O',
       '4 BFILE reads',     '2 disk I/O',
       '5 other I/O',     '2 disk I/O',
       '1 DBWn writes',   '3 waits',
       '2 LGWR writes',     '3 waits',
       '3 ARCn writes',     '3 waits',
       '4 enqueue locks',   '3 waits',
       '5 PCM locks',     '3 waits',
       '6 other locks',     '3 waits',
       '1 commits',     '4 latency',
       '2 network',     '4 latency',
       '3 file ops',      '4 latency',
       '4 process ctl',     '4 latency',
       '5 global locks',    '4 latency',
       '6 misc',      '4 latency')  n_major,
       n_minor,
       wait_event,
       time
FROM  (SELECT /*+ ordered use_hash(b) use_nl(d) */
      DECODE(d.kslednam,
  -- disk I/O
              'db file sequential read',      '1 normal I/O',
              'db file scattered read',       '2 full scans',
              'BFILE read',           '4 BFILE reads',
                    'KOLF: Register LFI read',      '4 BFILE reads',
              'log file sequential read',       '5 other I/O',
              'log file single write',      '5 other I/O',
      -- resource waits
              'checkpoint completed',       '1 DBWn writes',
              'free buffer waits',        '1 DBWn writes',
              'write complete waits',       '1 DBWn writes',
              'local write wait',         '1 DBWn writes',
              'log file switch (checkpoint incomplete)','1 DBWn writes',
              'rdbms ipc reply',          '1 DBWn writes',
              'log file switch (archiving needed)',   '3 ARCn writes',
              'enqueue',            '4 enqueue locks',
              'buffer busy due to global cache',    '5 PCM locks',
              'global cache cr request',      '5 PCM locks',
              'global cache lock cleanup',      '5 PCM locks',
              'global cache lock null to s',      '5 PCM locks',
              'global cache lock null to x',      '5 PCM locks',
              'global cache lock s to x',       '5 PCM locks',
              'lock element cleanup',       '5 PCM locks',
              'checkpoint range buffer not saved',  '6 other locks',
              'dupl. cluster key',        '6 other locks',
              'PX Deq Credit: free buffer',     '6 other locks',
              'PX Deq Credit: need buffer',     '6 other locks',
              'PX Deq Credit: send blkd',       '6 other locks',
              'PX qref latch',          '6 other locks',
              'Wait for credit - free buffer',    '6 other locks',
              'Wait for credit - need buffer to send',  '6 other locks',
              'Wait for credit - send blocked',   '6 other locks',
              'global cache freelist wait',     '6 other locks',
              'global cache lock busy',       '6 other locks',
              'index block split',        '6 other locks',
              'lock element waits',         '6 other locks',
              'parallel query qref latch',      '6 other locks',
              'pipe put',             '6 other locks',
              'rdbms ipc message block',      '6 other locks',
              'row cache lock',         '6 other locks',
              'sort segment request',       '6 other locks',
              'transaction',          '6 other locks',
              'unbound tx',           '6 other locks',
      -- routine waits
              'log file sync',          '1 commits',
              'name-service call wait',       '2 network',
              'Test if message present',      '4 process ctl',
              'process startup',          '4 process ctl',
              'read SCN lock',          '5 global locks',
              DECODE(SUBSTR(d.kslednam, 1, INSTR(d.kslednam, ' ')),
      -- disk I/O
                'direct ',            '3 direct I/O',
                'control ',           '5 other I/O',
                'db ',            '5 other I/O',
      -- resource waits
                'log ',             '2 LGWR writes',
                'buffer ',            '6 other locks',
                'free ',            '6 other locks',
                'latch ',             '6 other locks',
                'library ',           '6 other locks',
                'undo ',            '6 other locks',
      -- routine waits
                'SQL*Net ',           '2 network',
                'BFILE ',             '3 file ops',
                'KOLF: ',             '3 file ops',
                'file ',            '3 file ops',
                'KXFQ: ',             '4 process ctl',
                'KXFX: ',             '4 process ctl',
                'PX ',            '4 process ctl',
                'Wait ',            '4 process ctl',
                'inactive ',            '4 process ctl',
                'multiple ',            '4 process ctl',
                'parallel ',            '4 process ctl',
                'DFS ',             '5 global locks',
                'batched ',           '5 global locks',
                'on-going ',            '5 global locks',
                'global ',            '5 global locks',
                'wait ',            '5 global locks',
                'writes ',            '5 global locks',
                    '6 misc'))  n_minor,
          d.kslednam  wait_event,         -- event name
          i.kslestim_fg - nvl(b.time, 0)  time     -- non-background time
       FROM   sys.x$kslei  i,          -- system events
         (SELECT /*+ ordered use_hash(e) */     -- no fixed index on e
               e.kslesenm,          -- event number
               SUM(e.kslestim)  time        -- time waited by backgrounds
            FROM   sys.x$ksuse  s,         -- sessions
               sys.x$ksbdp  b,         -- backgrounds
               sys.x$ksles  e          -- session events
            WHERE  s.ksspaown = b.ksbdppro        -- background session
              AND    e.kslessid = s.indx
              GROUP  BY e.kslesenm
            HAVING SUM(e.kslestim) > 0)  b,
       sys.x$ksled  d
       WHERE  i.kslestim_fg > 0
       AND    b.kslesenm (+) = i.indx
       AND    nvl(b.time, 0) < i.kslestim_fg
       AND    d.indx = i.indx
       AND    d.kslednam NOT IN  ('Null event',
              'KXFQ: Dequeue Range Keys - Slave',
              'KXFQ: Dequeuing samples',
              'KXFQ: kxfqdeq - dequeue from specific qref',
              'KXFQ: kxfqdeq - normal deqeue',
              'KXFX: Execution Message Dequeue - Slave',
              'KXFX: Parse Reply Dequeue - Query Coord',
              'KXFX: Reply Message Dequeue - Query Coord',
              'PAR RECOV : Dequeue msg - Slave',
              'PAR RECOV : Wait for reply - Query Coord',
              'Parallel Query Idle Wait - Slaves',
              'PL/SQL lock timer',
              'PX Deq Credit: send blkd',
              'PX Deq Credit: need buffer',
              'PX Deq: Execute Reply',
              'PX Deq: Execution Msg',
              'PX Deq: Index Merge Execute',
              'PX Deq: Index Merge Reply',
              'PX Deq: Par Recov Change Vector',
              'PX Deq: Par Recov Execute',
              'PX Deq: Par Recov Reply',
              'PX Deq: Parse Reply',
              'PX Deq: Table Q Get Keys',
              'PX Deq: Table Q Normal',
              'PX Deq: Table Q Sample',
              'PX Deq: Table Q qref',
              'PX Deq: Txn Recovery Reply',
              'PX Deq: Txn Recovery Start',
              'PX Deque wait',
              'PX Idle Wait',
              'Replication Dequeue',
              'Replication Dequeue ',
              'SQL*Net message from client',
              'SQL*Net message from dblink',
              'debugger command',
              'dispatcher timer',
              'parallel query dequeue wait',
              'pipe get',
              'queue messages',
              'rdbms ipc message',
              'secondary event',
              'single-task message',
              'slave wait',
              'virtual circuit status',
              'lock element cleanup',
              'pmon timer',
              'rdbms ipc message',
              'rdbms ipc reply',
              'smon timer',
              'SQL*Net break/reset to client',
              'SQL*Net message to client',
              'SQL*Net more data from client',
              'dispatcher timer',
              'parallel query dequeue wait',
              'parallel query idle wait - Slaves',
              'pipe get',
              'PL/SQL lock timer',
              'slave wait',
              'virtual circuit status',
              'WMON goes to sleep',
              'jobq slave wait',
              'Queue Monitor Wait',
              'wakeup time manager')
       AND    d.kslednam not like 'resmgr:%'))
-- WHERE  round(time/100/3600) > 1000
ORDER  BY n_major,
      n_minor,
      time desc
/

exit;

