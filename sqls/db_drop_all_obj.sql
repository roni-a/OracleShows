--#######################################################################
--# Name    : Dba drop all objects ( TABLE , VIEW , SEQUENCE , SYNONYM)
--#           in the current user
--#######################################################################

set echo off
set feedback off
set linesize 500
set pagesize 0
set heading off
set verify  off
set termout off


SELECT 
    'DROP ' || OBJECT_TYPE || ' ' || OBJECT_NAME || 
    DECODE(OBJECT_TYPE,'TABLE',' CASCADE CONSTRAINTS ;' 
		              ,';')
FROM 
    USER_OBJECTS 
WHERE
      OBJECT_TYPE != 'INDEX'
 
spool tmp_db_drop_all_obj.sql
/
spool off

set linesize 500
set heading off
set termout on
set verify  off
set feedback on
set scan on
set echo on


start tmp_db_drop_all_obj.sql

!rm -f tmp_db_drop_all_obj.sql
