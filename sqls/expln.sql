set pages 0 lines 190 feedb off
col cardinality for 99,999

Rem
Rem Display last explain plan
Rem 
prompt RONI
select '+---+---+-------------------------------------------------------------------------+-------------------------------+--------+----------+------------+' from dual
union all
select '| ID|PID| Operation                                                               | Name                          |  Cost  |    Rows  |    Bytes   |' from dual
union all
select '+---+---+-------------------------------------------------------------------------+-------------------------------+--------+----------+------------+' from dual
union all
select * from 
(select /*+ no_merge */
       '|'|| lpad(id, 3, ' ') ||'|'|| lpad(decode(parent_id,null,' ',parent_id), 3, ' ') ||'|'||
       rpad(' '||substr(lpad(' ',2*(level-1))||operation||decode(options,null,'',' '||options),1,72),73,' ')
       ||'|'||
       rpad(' '||substr(object_name||' ',1, 30), 31, ' ')||'|'||
       lpad(decode(cost, null,' ',cost), 8, ' ') || '|' ||
       lpad(decode(cardinality, null,' ',cardinality), 10, ' ') || '|' ||
       lpad(decode(bytes, null,' ',bytes), 12, ' ') || '|'
from plan_table
start with id=0 and timestamp = (select max(timestamp) from plan_table 
                                 where id=0)
connect by prior id = parent_id 
        and prior nvl(statement_id, ' ') = nvl(statement_id, ' ')
        and prior timestamp <= timestamp
order by id, position)
union all
select '+---+---+-------------------------------------------------------------------------+-------------------------------+--------+----------+------------+' from dual
/
prompt

-- where statement_id = '&1'
