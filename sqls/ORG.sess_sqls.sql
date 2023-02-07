set feedback off
set serveroutput on size 1000000
set timin on
column username format a20
column sql_text format a55 word_wrapped

BEGIN
   FOR x IN
    (SELECT /*+ first_rows */ 
			      username || ' (' || inst_id || ',' || sid || ',' || serial# || ') ospid = ' || process || ' program = ' || program username,
            to_char(LOGON_TIME,' Day HH24:MI') logon_time,
            to_char(sysdate,' Day HH24:MI') current_time,
						inst_id,
            sql_address,
            sql_hash_value
     FROM   gv$session
     WHERE  status = 'ACTIVE'
     AND    RAWTOHEX(sql_address) <> '00'
     AND    username IS NOT NULL ) 
	 LOOP
    FOR y IN 
		  (SELECT /*+ first_rows */
				      sql_text
       FROM   gv$sqlarea
       WHERE  address = x.sql_address 
		   AND    inst_id = x.inst_id) 
		LOOP
      IF ( y.sql_text NOT LIKE '%listener.get_cmd%' AND
           y.sql_text NOT LIKE '%RAWTOHEX(SQL_ADDRESS)%' ) 
		  THEN
         dbms_output.put_line( '==========================================================' );
         dbms_output.put_line( x.username );
         dbms_output.put_line( x.logon_time || ' ' || x.current_time || ' SQL#=' || x.sql_hash_value);
         dbms_output.put_line( '----------------------------' );
         dbms_output.put_line( substr( y.sql_text, 1, 250 ) || ';' );
      END IF;
    END LOOP;
   END LOOP;
END;
/
exit
