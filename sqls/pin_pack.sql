CREATE OR REPLACE PROCEDURE pin_pkgs AS
BEGIN
   dbms_shared_pool.keep  ('SYS.STANDARD');
   dbms_shared_pool.keep  ('SYS.DBMS_STANDARD');
   dbms_shared_pool.keep  ('SYS.DBMS_DESCRIBE');
   dbms_shared_pool.keep  ('SYS.DBMS_OUTPUT');

END;
/

execute pin_pkgs;

