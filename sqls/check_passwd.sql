-- This script is called by password.
-- It checks if the passwords of SYS and SYSTEM 
-- are the same as in the given instance.

set head off
set ver off
set feed off
set echo off
SELECT username
FROM dba_users,v$database
WHERE (username = 'SYSTEM' and password <> '&&2')
or (username = 'SYS' and password <> '&&1');
exit

