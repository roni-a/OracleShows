set serverout on feedback off
DECLARE
   time_1 BINARY_INTEGER;
   time_2 BINARY_INTEGER;
   time_3 BINARY_INTEGER;
   value_1 NUMBER;
   value_2 NUMBER;
   value_3 NUMBER;
BEGIN
   time_1 := DBMS_UTILITY.GET_TIME;
   SELECT value INTO value_1
   FROM   v$sysstat
   where STATISTIC# = 4;

sys.accusleep(1);
   time_2 := DBMS_UTILITY.GET_TIME;
   SELECT value INTO value_2
   FROM   v$sysstat
   where STATISTIC# = 4;

sys.accusleep(1);
   time_3 := DBMS_UTILITY.GET_TIME;
   SELECT value INTO value_3
   FROM   v$sysstat
   where STATISTIC# = 4;
DBMS_OUTPUT.PUT_LINE ('_');
DBMS_OUTPUT.PUT_LINE ('_    Commits Per Sec.: '||ROUND((((value_2 - value_1)/(time_2 - time_1)+(value_3 - value_2)/(time_3 - time_2))/2)*100));
DBMS_OUTPUT.PUT_LINE ('_');
end;
/

exit;

set echo off verify off feedback    off

col sval new_value xsval noprint
col stime new_value xstime noprint

select sum(VALUE) sval ,TO_NUMBER(TO_CHAR(SYSDATE,'HHMISS')) stime
    from v$sysstat
    where STATISTIC#=4;

!sleep 5

col eval new_value xeval noprint
col etime new_value xetime noprint

select sum(VALUE) eval ,TO_NUMBER(TO_CHAR(SYSDATE,'HHMISS')) etime
    from v$sysstat
    where STATISTIC#=4;

select round((&xeval - &xsval)/(&xetime - &xstime)) "Commits Per Sec." from dual;

prompt
prompt

exit;

