set echo off verif off feedback off
set lines 1250
set pages 0
set long 1000000
set longchunksize 10000
EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE', FALSE);
EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',TRUE);
EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',TRUE);

-- EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',FALSE);
-- EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',TRUE);
-- EXECUTE dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SPECIFICATION',FALSE);

SELECT DBMS_METADATA.get_ddl ('TABLE', table_name, owner)
FROM all_tables
WHERE owner = UPPER('&1') AND table_name = UPPER('&2')
/
-- UNION ALL
SELECT DBMS_METADATA.get_dependent_ddl ('COMMENT', table_name, owner)
FROM (SELECT table_name, owner
FROM all_col_comments
WHERE owner = UPPER('&1') AND table_name = UPPER('&2') AND comments IS NOT NULL
UNION
SELECT table_name, owner
FROM all_tab_comments
WHERE owner = UPPER('&1') AND table_name = UPPER('&2') AND comments IS NOT NULL)
/
--- UNION ALL
SELECT DBMS_METADATA.get_dependent_ddl ('INDEX', table_name, table_owner)
FROM all_indexes
WHERE table_owner = UPPER('&1')
AND table_name = UPPER('&2')
AND index_name NOT IN (
SELECT constraint_name
FROM SYS.all_constraints
WHERE table_name = table_name
AND constraint_type = 'P')
AND uniqueness != 'UNIQUE'
/

-- DECLARE
--    CURSOR idx_cur IS
-- 	SELECT index_name, table_owner
-- 	FROM   all_indexes
-- 	WHERE  table_owner = UPPER('&1')
-- 	AND    table_name = UPPER('&2')
-- 	AND    index_name NOT IN (SELECT constraint_name
-- 				  FROM   all_constraints
-- 				  WHERE  table_name = table_name
-- 				  AND    constraint_type = 'P')
-- 	AND    uniqueness != 'UNIQUE';
-- 
--    v_idx_txt			VARCHAR2(4000);
-- BEGIN
--    FOR rec_idx IN idx_cur
--    LOOP
--       SELECT DBMS_METADATA.get_ddl ('INDEX', index_name, table_owner)
--       INTO   v_idx_txt
--       FROM   all_indexes 
--       WHERE  table_owner = UPPER('&1')
--       AND    table_name = UPPER('&2')
--       AND    index_name = rec_idx.index_name;
-- 
--       DBMS_OUTPUT.PUT_LINE(v_idx_txt);
--    END LOOP;
-- END;
-- /

-- UNION ALL
SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner)
FROM all_triggers
WHERE table_owner = UPPER('&1') AND table_name = UPPER('&2')
/
exit

