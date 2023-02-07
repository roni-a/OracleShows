select o.name object_name, u.name owner, lid.*
  from (select
               s.inst_id, s.sid, s.serial#, p.spid,nvl (s.sql_id, 0), s.sql_hash_value,
               decode (l.type,
                       'tm', l.id1,
                       'tx', decode (l.request,
                                     0, nvl (lo.object_id, -1),
                                     s.row_wait_obj#
                                    ),
                       -1
                      ) as object_id,
                 l.type lock_type,
               DECODE (l.lmode,
                       0, 'NONE',
                       1, 'NULL',
                       2, 'ROW SHARE',
                       3, 'ROW EXCLUSIVE',
                       4, 'SHARE',
                       5, 'SHARE ROW EXCLUSIVE',
                       6, 'EXCLUSIVE',
                       '?'
                      ) mode_held,
               DECODE (l.request,
                       0, 'NONE',
                       1, 'NULL',
                       2, 'ROW SHARE',
                       3, 'ROW EXCLUSIVE',
                       4, 'SHARE',
                       5, 'SHARE ROW EXCLUSIVE',
                       6, 'EXCLUSIVE',
                       '?'
                      ) mode_requested,
               l.id1, l.id2, l.ctime time_in_mode,s.row_wait_obj#, s.row_wait_block#,
               s.row_wait_row#, s.row_wait_file#
          from gv$lock l,
               gv$session s,
               gv$process p,
               (select object_id, session_id, xidsqn
                  from gv$locked_object
                 where xidsqn > 0) lo
         where l.inst_id = s.inst_id
           and s.inst_id = p.inst_id
           and s.sid = l.sid
           and p.addr = s.paddr
           and l.sid = lo.session_id(+)
           and l.id2 = lo.xidsqn(+)) lid,
       SYS.obj$ o,
       SYS.user$ u
 WHERE o.obj#(+) = lid.object_id
 AND o.owner# = u.user#(+)
 AND object_id <> -1;

exit
