rem
rem	Script:		get_text.sql
rem	Author:		J.P.Lewis
rem	Last Update:	01-June-1998
rem	Purpose:	Get recent SQL Text for an Oracle Username
rem
rem	Input variables:
rem		Oracle Username of the user
rem	Notes:
rem		The linesize of 64 is MOST important
rem		You really shouldn't hit v$sqltext like this
rem
set lines 64 pagesize 0 feedback off trimspool off verify off
clear columns
clear breaks
define m_sess=&1

SELECT RTRIM(UPPER(sql_text))
  FROM v$sqltext
 WHERE hash_value IN (SELECT sql_hash_value
                      FROM   v$session
                      WHERE  sid = &m_sess
                      UNION
                      SELECT prev_hash_value
                      FROM   v$session
                      WHERE  sid = &m_sess)
 ORDER BY hash_value
     , piece;

exit;
