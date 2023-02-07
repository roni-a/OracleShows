REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show datafile in backup mode 
REM ------------------------------------------------------------------------

set linesize    96
set pages       100
set feedback    off
set head	off

SELECT is_active
FROM (SELECT count(decode(status,'ACTIVE',1)) is_active
      FROM v$backup)
WHERE is_active > 0
;

prompt

exit

