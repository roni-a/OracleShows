set pages 0 lines 170 feedb off
prompt RONI

select '+---+---+-------------------------------------------------------------------------+-------------------------------+--------+----------+------------+' from dual
union all
select '| ID|PID| Operation                                                               | Name                          |  Cost  |    Rows  |    Bytes   |' from dual
union all
select '+---+---+-------------------------------------------------------------------------+-------------------------------+--------+----------+------------+' from dual
union all
select * from
(select /*+ no_merge */
       rpad('|'||lpad(id, 3, ' '), 4, ' ')||'|'||
       lpad(decode(parent_id,null,' ',parent_id), 3, ' ')||'|'||
       rpad(' '||substr(lpad(' ',2*(level-1))||operation||
            decode(options, null,'',' '||options), 1, 72), 73, ' ')||'|'||
       rpad(substr(object_name||' ',1, 30), 31, ' ')||'|'||
       lpad(decode(cost, null,' ',cost), 8, ' ') || '|' ||
       lpad(decode(cardinality, null,' ',cardinality), 10, ' ') || '|' || 
       lpad(decode(bytes, null,' ',bytes), 12, ' ') || '|' as "Explain plan"
from plan_table
where statement_id = '&1'
start with id = 0
connect by prior id = parent_id
        and prior nvl(statement_id, ' ') = nvl(statement_id, ' ')
        and prior timestamp <= timestamp
order by id, position)
union all
select '+---+---+-------------------------------------------------------------------------+-------------------------------+--------+----------+------------+' from dual
/
prompt  &1

