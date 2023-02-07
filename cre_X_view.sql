set pagesize 0
set termout off
set echo off

spool create_xviews.tmp
prompt set echo on
select 
  'create or replace view X_$' || substr(name, 3) ||
  ' as select * from ' || name || ';'
from
  sys.v_$fixed_table
where
  name like 'X$%'
order by name
/
spool off

@create_xviews.tmp

set termout off
host rm -f create_xviews.tmp	-- for Unix

