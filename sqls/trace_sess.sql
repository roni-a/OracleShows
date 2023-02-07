echo $SID
echo $SERIAL
sqlplus / <<*EOF*
alter system set timed_statistics=true;
exec sys.dbms_system.set_sql_trace_in_session('$1','$2',true);
*EOF*

#exec sys.dbms_system.set_sql_trace_in_session('$1','$2',true);

