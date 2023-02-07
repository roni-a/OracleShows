set serverout on size 1000000

CREATE USER &&1 IDENTIFIED BY "123456" 
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp;

GRANT CONNECT TO &&1;
GRANT CREATE SESSION TO &&1;

BEGIN
   FOR R IN (SELECT owner, DECODE(iot_name,NULL,table_name,iot_name) table_name FROM all_tables WHERE owner=UPPER('&&2')) LOOP
      EXECUTE IMMEDIATE 'grant select on '||R.owner||'.'||R.table_name||' to ' || UPPER('&&1');
   END LOOP;
END;
/

exit
