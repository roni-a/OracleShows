REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ tables
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show ddatabase users 
REM ------------------------------------------------------------------------

set linesize    120 
set pagesize	9999
set feedback    off

col username		for a28 	head "User Name"
col default_tablespace	for a35 	head "Default|Tablespace"
col MB  	 	for 9,999,999.9	head "Tot Used|(MB)"
col QT 			for a10 	head "Tot Quota|(MB)"

column name new_value dbname noprint
SELECT name FROM v$database
;
ttitle dbname ' USERS :' skip -
       '============'
btitle off

set termout off
spool &1 

SELECT count(*) FROM dba_users
;
ttitle off

SELECT u.username, default_tablespace, round(bytes/1024/1024,1) MB, 
       decode(sign(max_bytes),-1,'Unlimited',0,0,round(max_bytes/1024/1024,1)) QT, created
FROM dba_users u, dba_ts_quotas q
WHERE u.username = q.username (+) 
   AND   u.default_tablespace = q.tablespace_name (+)
AND u.username NOT IN
('WKPROXY',
'MDDATA',
'EXFSYS',
'ANONYMOUS',
'ORDSYS',
'MGMT_VIEW',
'QA_ART_ADM',
'ORDPLUGINS',
'MDSYS',
'CTXSYS',
'SCOTT',
'WKSYS',
'DBSNMP',
'XDB',
'SYS',
'OUTLN',
'TSMSYS',
'OPS$ORACLE',
'SI_INFORMTN_SCHEMA',
'SYSTEM',
'DIP',
'ORAEXP',
'WMSYS',
'SYSMAN',
'OLAPSYS',
'WK_TEST',
'DMSYS')
ORDER BY 1 -- bytes desc
/
prompt
spool off

exit

