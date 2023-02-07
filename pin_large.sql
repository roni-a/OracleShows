set termout on
set serveroutput on

spool pin

begin  

   for obj in (    
	select nvl(owner,user)||'.'||name name    
	from   v$db_object_cache    
	where sharable_mem > 10000    
	and (type = 'PACKAGE' 
	    or type = 'PACKAGE BODY' 
	    or type = 'FUNCTION'    
   	    or type = 'PROCEDURE')    
	and kept = 'NO' )  
	loop    
	   begin      
		sys.dbms_shared_pool.keep(obj.name);      
		sys.dbms_output.put_line(obj.name || ' pinned');    
	   end;  
	end loop;
   end;
/

spool off
set serveroutput off
