set feedback off echo off veri off
set serveroutput on size 1000000
set timin on
column username format a20
column sql_text format a55 word_wrapped

drop table tmp_sess;
create table tmp_sess as
                 SELECT /*+ first_rows */
            RPAD(s.username,12,' ') || '| ' || s.inst_id || ' | ' || LPAD(s.sid,5,' ') || ' | ' || LPAD(s.serial#,5,' ') || '| ospid = ' || s.process || ' | program = ' || s.program username,
            to_char(s.LOGON_TIME,' DD/MM HH24:MI') logon_time,
            to_char(sysdate,' DD/MM HH24:MI') current_time,
            s.inst_id,
            s.sql_address,
            s.sql_hash_value,
                                                sa.sql_text
     FROM   gv$session s,
                        gv$sqlarea sa
     WHERE  status = 'ACTIVE'
     AND    RAWTOHEX(sql_address) <> '00'
     AND    username IS NOT NULL
     AND    username LIKE UPPER('&&1%')
                 AND    s.sql_address = sa.address
                 AND    s.inst_id     = sa.inst_id
/

BEGIN
   FOR x IN
    (SELECT *
     FROM   tmp_sess
           ORDER  BY 1)
   LOOP
      IF ( x.sql_text NOT LIKE '%listener.get_cmd%' AND
           x.sql_text NOT LIKE '%RAWTOHEX(SQL_ADDRESS)%' )
      THEN
         dbms_output.put_line( '========================================================================================================================' );
         dbms_output.put_line( x.username );
         dbms_output.put_line( '------------+----+------+--+---+---------------+--' );
         dbms_output.put_line( x.logon_time || ' | ' || x.current_time || ' | SQL#=' || x.sql_hash_value);
         dbms_output.put_line( '------------+--------------+----------------------' );
         IF LENGTH(x.sql_text) < 250 THEN
            dbms_output.put_line( substr( x.sql_text, 1, 250 ) || ';' );
         ELSE
            dbms_output.put_line( substr( x.sql_text, 1, 250 ) || ' .../' );
         END IF;
      END IF;
   END LOOP;
   dbms_output.put_line( '========================================================================================================================' );
END;
/
exit
