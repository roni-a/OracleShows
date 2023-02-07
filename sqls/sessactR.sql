REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ 
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show active sessions 
REM ------------------------------------------------------------------------

set linesize    140
set pages       100
set feedback    off
set verify	off

col sid		for 99999 trunc 
col INST_ID for 999 head "Ins|ID"
col serial#	for 99999 trunc	head SER#
col username	for a12 trunc	head "User Name" 
col osuser      for a10 trunc   head "OS User"
col process     for a13          head "Process"      
col program	for a14 trunc	head Program
col command     for a20                 head "Command"
col logon       for a15                 head "Logon Time"
col DEGREE			for 999			head "Prll|Dgre"
col REQ_DEGREE	for 999			head "Req|Prll"
col degra				for 999			head "Degrad|uation"

define _user_name=&1

tti "Active Transactions|========================="

SELECT 
  distinct s.sid,
	s.serial#, 
	s.inst_id,
	substr(username,1,12) username,
       	substr(osuser,1,10) osuser, 
	process, 
	program, 
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
        TO_CHAR(LOGON_TIME,'DD/MM/YY_HH24:MI') logon,
				REQ_DEGREE,
				DEGREE,
				(DEGREE - REQ_DEGREE) degra
FROM gv$session s,
		 gv$px_session ps
WHERE s.sid > 7 
  AND s.sid = ps.sid (+)
	AND s.inst_id = ps.inst_id (+)
	AND s.serial# = ps.serial# (+)
  AND status = 'ACTIVE'
  AND username like upper('&_user_name')
ORDER BY 3,1,2
/

prompt

exit

