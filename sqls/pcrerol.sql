REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on sys.dba_ tables
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Create script for user's roles creation
REM ------------------------------------------------------------------------

set verify off
set feedback off
set termout off
set echo off
set pagesize 0

spool &2\.sql

prompt spool &2\.log
prompt

SELECT 'CREATE ROLE ' || lower(role) || ' NOT IDENTIFIED;'
FROM sys.dba_roles
WHERE role not in ('CONNECT','RESOURCE','DBA', 'EXP_FULL_DATABASE',
                    'IMP_FULL_DATABASE')
 AND password_required='NO'
;

SELECT 'CREATE ROLE ' || lower(role) || ' IDENTIFIED BY VALUES ' ||
       '''' || password || '''' || ';'
FROM sys.dba_roles, sys.user$
WHERE role not in ('CONNECT','RESOURCE','DBA', 'EXP_FULL_DATABASE',
                    'IMP_FULL_DATABASE')
  AND password_required='YES' 
  AND dba_roles.role=user$.name
;
SELECT 'GRANT ' || lower(privilege) || ' TO ' || lower(role) || 'WITH ADMIN OPTI
ON;'
FROM role_sys_privs
WHERE role not in ('DBA', 'EXP_FULL_DATABASE','IMP_FULL_DATABASE')
and admin_option='YES'
;


SELECT 'GRANT ' || lower(privilege) || ' TO ' || lower(role) || ';'
FROM role_sys_privs
WHERE role not in ('DBA', 'EXP_FULL_DATABASE','IMP_FULL_DATABASE')
and admin_option='NO'
;



SELECT 'GRANT ' || lower(granted_role) || ' TO ' || lower(grantee) ||
       ' WITH ADMIN OPTION;'
FROM sys.dba_role_privs
WHERE admin_option='YES'
  AND granted_role not in ('CONNECT','RESOURCE','DBA', 'EXP_FULL_DATABASE',
                           'IMP_FULL_DATABASE')
  AND grantee &1
ORDER BY grantee
;

SELECT 'GRANT ' || lower(PRIVILEGE)|| ' TO ' || lower(grantee) ||';'
FROM dba_sys_privs
WHERE GRANTEE &1
  AND GRANTEE in (SELECT username
                  FROM dba_users 
                  WHERE dba_sys_privs.grantee=dba_users.username)
;

SELECT 'GRANT ' || lower(granted_role) || ' TO ' || lower(grantee) ||';'
FROM sys.dba_role_privs
WHERE admin_option='NO'
AND granted_role not in ('CONNECT','RESOURCE','DBA', 'EXP_FULL_DATABASE','IMP_FULL_DATABASE')
AND grantee &1
ORDER BY grantee
;

SELECT 'GRANT ' || lower(granted_role) || ' TO PUBLIC;'
FROM sys.DBA_ROLE_PRIVS
WHERE GRANTEE='PUBLIC';

SELECT 'GRANT '|| lower(PRIVILEGE) ||  ' TO PUBLIC;'
FROM sys.USER_SYS_PRIVS
WHERE USERNAME='PUBLIC';


prompt spool off
prompt exit

spool off

exit


