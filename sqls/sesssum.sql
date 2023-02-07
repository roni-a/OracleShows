SELECT 1 Dummy,
  p.INST_ID,
       SUM (DECODE (s.TYPE, 'BACKGROUND', 1, 0)) system_sessions,
       SUM (DECODE (s.username, NULL, 0, DECODE (s.status, 'ACTIVE', 1, 0)))
          active_users,
       SUM (DECODE (s.username, NULL, 0, DECODE (s.status, 'ACTIVE', 0, 1)))
          inactive_users,
       SUM (
          DECODE (s.TYPE,
                  'BACKGROUND', 0,
                  DECODE (s.server, 'DEDICATED', 1, 0)))
       - SUM (
            DECODE (
               s.TYPE,
               'BACKGROUND', 0,
               DECODE (
                  s.username,
                  NULL, DECODE (SIGN (INSTR (p.program, '(J')), 0, 0, 1),
                  0)))
       - SUM (
            DECODE (
               s.TYPE,
               'BACKGROUND', 0,
               DECODE (
                  s.username,
                  NULL, DECODE (SIGN (INSTR (p.program, '(CJQ')), 0, 0, 1),
                  0)))
          dedicated,
       SUM (DECODE (s.username, NULL, 0, 1)) user_sessions
  FROM gv$session s, gv$process p
 WHERE p.addr = s.paddr
 AND  p.INST_ID = s.INST_ID
 GROUP BY p.INST_ID
/
exit
