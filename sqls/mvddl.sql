REM LOCATION:   Object Management\Materialized Views and Materialized View Logs
REM FUNCTION:   Get Oracle to create the DDL for your fast refresh Mview For you.
REM TESTED ON:  10.2.0.3, 11.1.0.6
REM PLATFORM:   non-specific
REM REQUIRES:   dbms_metadata, dbms_advisor
REM
REM  This is a part of the Knowledge Xpert for Oracle Administration library.
REM  Copyright (C) 2008 Quest Software
REM  All rights reserved.
REM
REM  Note: The result of this code will be create mview log and create mview
REM        statements that you can use to re-create your exiting mviews or create
REM        new mviews as fast refreshable.
REM ******************** Knowledge Xpert for Oracle Administration ********************
SET serveroutput on feedback off echo off veri off

UNDEF ENTER_MVIEW_OWNER
UNDEF ENTER_MVIEW_NAME

DEFINE ENTER_MVIEW_NAME=&1
DEFINE ENTER_MVIEW_OWNER=&2

DECLARE
   v_task_name     VARCHAR2 (100);
   v_mview_owner   VARCHAR2 (30)   := UPPER ('&&ENTER_MVIEW_OWNER');
   v_mview_name    VARCHAR2 (30)   := UPPER ('&&ENTER_MVIEW_NAME');
   v_sql           VARCHAR2 (4000);
BEGIN
   -- get mview text from data dictionary
    SELECT DBMS_METADATA.get_ddl ('MATERIALIZED_VIEW', mview_name, owner)
     INTO v_sql
     FROM dba_mviews
    WHERE owner = v_mview_owner AND mview_name = v_mview_name;

   DBMS_OUTPUT.put_line ('MVIEW SQL Is: ' || v_sql);
--   DBMS_ADVISOR.tune_mview (v_task_name, v_sql);
   DBMS_OUTPUT.put_line (CHR (13));
   DBMS_OUTPUT.put_line ('SQL Commands to create fast refresh Materialized View');
   DBMS_OUTPUT.put_line (CHR (13));
   DBMS_OUTPUT.put_line ('Original Mview Code: ');
   DBMS_OUTPUT.put_line (v_sql);
   DBMS_OUTPUT.put_line (CHR (13));

   FOR tt IN (SELECT action_id, STATEMENT
                FROM dba_tune_mview
               WHERE script_type = 'IMPLEMENTATION'
                 AND task_name = v_task_name
               ORDER BY action_id)
   LOOP
      DBMS_OUTPUT.put_line ('Statement Order Number: ' || tt.action_id);
      DBMS_OUTPUT.put_line ('Statement ID : ' || tt.STATEMENT);
      DBMS_OUTPUT.put_line (CHR (13));
   END LOOP;
-- You can also use the following query to look at the dba_tune_mview view:
-- select statement from dba_tune_mview
-- where script_type='IMPLEMENTATION'
-- and task_name=v_task_name
-- order by action_id;
END;
/
exit
