REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ 
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show sessions details
REM ------------------------------------------------------------------------

set linesize    140
set pages       100
set feedback    off
set verify 	off

col SID         for 999 trunc
col inst_id     for 999 trunc head "Ins|ID"
col serial#     for 99999 trunc 	head SER#
col username    for a&2 		head "User Name"
col osuser      for a10 trunc		head "Remote|OS User"
col network_service_banner for a3 trunc
col status      for a3 trunc
col command     for a20			head "Command"
col process     for a9 trunc		head "Remote|Process"
col spid        for a6 trunc		head "Local|Shadow|Process"
col program     for a18 trunc 		head Program

SELECT 
       sess.sid, 
			 sess.inst_id,
			 sess.serial#, sess.username, substr(conn.osuser,1,10) osuser, 
       decode(substr(conn.NETWORK_SERVICE_BANNER,0,3),'TCP','TCP','Ora','BEQ') Network,
       status, sess.process, proc.spid, sess.program, 
       upper(decode(nvl(command, 0),
                0,      '---',
                1,      'Create Table',
                2,      'Insert -',
                3,      'Select -',
                4,      'Create Clust',
                5,      'Alter Clust',
                6,      'Update -',
                7,      'Delete -',
                8,      'Drop -',
                9,      'Create Index',
                10,     'Drop Index',
                11,     'Alter Index',
                12,     'Drop Table',
                13,     'Create Seq',
                14,     'Alter Seq',
                15,     'Alter Table',
                16,     'Drop Seq',
                17,     'Grant',
                18,     'Revoke',
                19,     'Create Syn',
                20,     'Drop Syn',
                21,     'Create View',
                22,     'Drop View',
                23,     'Validate Ix',
                24,     'Create Proc',
                25,     'Alter Proc',
                26,     'Lock Table',
                27,     'No Operation',
                28,     'Rename',
                29,     'Comment',
                30,     'Audit',
                31,     'NoAudit',
                32,     'Create DBLink',
                33,     'Drop DB Link',
                34,     'Create Database',
                35,     'Alter Database',
                36,     'Create RBS',
                37,     'Alter RBS',
                38,     'Drop RBS',
                39,     'Create Tablespace',
                40,     'Alter Tablespace',
                41,     'Drop Tablespace',
                42,     'Alter Session',
                43,     'Alter User',
                44,     'Commit',
                45,     'Rollback',
                47,     'PL/SQL Exec',
                48,     'Set Transaction',
                49,     'Switch Log',
                50,     'Explain',
                51,     'Create User',
                52,     'Create Role',
                53,     'Drop User',
                54,     'Drop Role',
                55,     'Set Role',
                56,     'Create Schema',
                58,     'Alter Tracing',
                59,     'Create Trigger',
                61,     'Drop Trigger',
                62,     'Analyze Table',
                63,     'Analyze Index',
                69,     'Drop Procedure',
                71,     'Create Snap Log',
                72,     'Alter Snap Log',
                73,     'Drop Snap Log',
                74,     'Create Snapshot',
                75,     'Alter Snapshot',
                76,     'Drop Snapshot',
                85,     'Truncate Table',
                88,     'Alter View',
                91,     'Create Function',
                92,     'Alter Function',
                93,     'Drop Function',
                94,     'Create Package',
                95,     'Alter Package',
                96,     'Drop Package',
                46,     'Savepoint')) Command,
        TO_CHAR(LOGON_TIME,'DD/MM/YY_HH24:MI') "Logon Time"
FROM  gv$session sess, 
      gv$sesstat stat, 
      v$statname name , 
      gv$process proc, 
      gv$session_connect_info conn
WHERE sess.sid = stat.sid 
and sess.inst_id = stat.inst_id
AND   conn.sid(+) = sess.sid 
and conn.INST_ID = sess.INST_ID
AND   stat.statistic# = name.statistic#
-- AND   sess.username like upper('&1')
AND   name.name =  'recursive calls'
AND   sess.paddr = proc.addr
and sess.inst_id = proc.inst_id
AND   conn.NETWORK_SERVICE_BANNER not like 'Advanced Networking Option%'
AND   conn.NETWORK_SERVICE_BANNER not like 'Oracle Advanced Security%'
ORDER BY 3,1,2
/
prompt

exit

