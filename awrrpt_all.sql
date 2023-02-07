REM --------------------------------------------------------------------------------------------------                                                          
REM Author: Riyaj Shamsudeen @OraInternals, LLC                                                                                                                 
REM         www.orainternals.com                                                                                                                                
REM                                                                                                                                                             
REM Functionality: This script is to get all AWR report from all nodes.                                                                                         
REM **************                                                                                                                                              
REM                                                                                                                                                             
REM Source  : AWR tables                                                                                                                                        
REM                                                                                                                                                             
REM Exectution type: Execute from sqlplus or any other tool.                                                                                                    
REM                                                                                                                                                             
REM Parameters: No parameters. Uses Last snapshot and the one prior snap                                                                                        
REM No implied or explicit warranty                                                                                                                             
REM @Copyright OraInternals, LLC                                                                                                                                
REM Please send me an email to rshamsud@orainternals.com, if you found issues in this script.                                                                   
REM --------------------------------------------------------------------------------------------------                                                          
set pages 0 lines 250                                                                                                                                           
variable dbid number                                                                                                                                            
variable inst_num number                                                                                                                                        
variable bid number                                                                                                                                             
variable eid number                                                                                                                                             
variable rpt_options number                                                                                                                                     
declare                                                                                                                                                         
begin                                                                                                                                                           
select                                                                                                                                                          
(select distinct first_value (snap_id) over(                                                                                                                    
order by snap_id desc rows between unbounded preceding and unbounded following) prior_snap_id                                                                   
from  dba_hist_snapshot                                                                                                                                         
where snap_id < max_snap_id                                                                                                                                     
) bid,                                                                                                                                                          
max_snap_id eid                                                                                                                                                 
into :bid, :eid                                                                                                                                                 
from                                                                                                                                                            
(                                                                                                                                                               
	select distinct first_value (snap_id) over(                                                                                                                    
		order by snap_id desc rows between unbounded preceding and unbounded following) max_snap_id                                                                   
	from  dba_hist_snapshot );                                                                                                                                     
select dbid into :dbid from dba_hist_database_instance where rownum=1;                                                                                          
end;                                                                                                                                                            
/                                                                                                                                                               
exec :rpt_options :=0;                                                                                                                                          
column rpt_name new_value rpt_name noprint;                                                                                                                     
exec :inst_num :=1;                                                                                                                                             
select 'awrrpt_'||:inst_num||'_'||:bid||'_'||:eid||'.txt' rpt_name from dual;                                                                                   
spool &rpt_name                                                                                                                                                 
select output from table(dbms_workload_repository.awr_report_text( :dbid,                                                                                       
:inst_num,                                                                                                                                                      
:bid, :eid,                                                                                                                                                     
:rpt_options ));                                                                                                                                                
spool off                                                                                                                                                       
set termout on                                                                                                                                                  
PROMPT    ...AWR report created for instance 1. Please wait..                                                                                                   
set termout off                                                                                                                                                 
exec :inst_num :=2;                                                                                                                                             
select 'awrrpt_'||:inst_num||'_'||:bid||'_'||:eid||'.txt' rpt_name from dual;                                                                                   
spool &rpt_name                                                                                                                                                 
select output from table(dbms_workload_repository.awr_report_text( :dbid,                                                                                       
:inst_num,                                                                                                                                                      
:bid, :eid,                                                                                                                                                     
:rpt_options ));                                                                                                                                                
spool off                                                                                                                                                       
set termout on                                                                                                                                                  
PROMPT    ...AWR report created for instance 2. Please wait..                                                                                                   
set termout off                                                                                                                                                 
