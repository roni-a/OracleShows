set termout off
set echo off
set head off
set pagesize 999
set feed off

spool create_xviews.tmp
prompt set echo on
select
  'create or replace view X_$' || substr(name, 3) ||
  ' as select * from ' || name || ';'
from
  sys.v_$fixed_table
where
  name like 'X$%'
/
spool off
@create_xviews.tmp
