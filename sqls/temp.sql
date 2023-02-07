SQL> 
SQL> 
SQL> SELECT 'SET SQLPROMPT "' || Lower(User) || ':' || :v_database || '> "'
  2  FROM   dual;

'SETSQLPROMPT"'||LOWER(USER)||':'||:V_DATABASE||'>"'                            
--------------------------------------------------------------------------------
SET SQLPROMPT "ops$oracle:sagi> "                                               
SQL> SPOOL OFF
