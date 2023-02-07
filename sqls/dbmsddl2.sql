set echo off verif off feedback off
set lines 1340
set pages 0
set long 1000000
set longchunksize 5000

define Type=&1
define Name=&2
define Owner=&3

EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE', FALSE);
EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',TRUE);
EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',TRUE);
-- EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',FALSE);
EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',TRUE);
-- EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SPECIFICATION',FALSE);

SELECT DBMS_METADATA.get_ddl (UPPER('&Type'), UPPER('&Name'), UPPER('&Owner'))
FROM dual
/
exit
