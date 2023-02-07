set echo off verif off feedback off
set lines 1250
set pages 0
set long 1000000
set longchunksize 10000
/*
CREATE OR REPLACE FUNCTION get_search_condition(p_cons_name IN VARCHAR2 ) 
RETURN VARCHAR2 authid current_user
IS
   l_search_condition user_constraints.search_condition%TYPE;
BEGIN
   SELECT search_condition into l_search_condition
   FROM   user_constraints
   WHERE  constraint_name = p_cons_name;

   RETURN l_search_condition;
END;
*/

EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE', FALSE);
EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',TRUE);
EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',TRUE);

-- EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',FALSE);
-- EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',TRUE);
-- EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SPECIFICATION',FALSE);

SELECT DBMS_METADATA.get_ddl ('TABLE', table_name, owner)
  FROM all_tables
 WHERE owner = UPPER('&1') 
   AND table_name = UPPER('&2')
/
SELECT DBMS_METADATA.get_dependent_ddl ('COMMENT', table_name, owner)
  FROM (SELECT table_name, owner
          FROM all_col_comments
         WHERE owner      = UPPER('&1') 
           AND table_name = UPPER('&2') 
           AND comments IS NOT NULL
        UNION ALL
        SELECT table_name, owner
          FROM all_tab_comments
         WHERE owner      = UPPER('&1') 
           AND table_name = UPPER('&2') 
           AND comments IS NOT NULL)
/
SELECT DBMS_METADATA.get_dependent_ddl ('INDEX', table_name, table_owner)
  FROM all_indexes ai
 WHERE table_owner = UPPER('&1')
   AND table_name = UPPER('&2')
   AND index_name NOT IN (SELECT constraint_name
			                      FROM SYS.all_constraints ac
--			                     WHERE ac.table_name = ai.table_name
--                             AND ac.owner      = ai.owner
                           WHERE table_owner = UPPER('&1')
                             AND table_name = UPPER('&2')
			                       AND constraint_type = 'P')
   AND uniqueness != 'UNIQUE'
/
SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner)
  FROM all_triggers
 WHERE table_owner = UPPER('&1') 
   AND table_name = UPPER('&2')
/

SELECT DBMS_METADATA.GET_DDL('CONSTRAINT', constraint_name, owner) AS ddl_constraints
  FROM user_constraints
 WHERE owner = UPPER('&1')
   AND table_name = UPPER('&2')
   AND constraint_type != 'P'
   AND get_search_condition(constraint_name) NOT LIKE '%NOT NULL%'
/
exit

