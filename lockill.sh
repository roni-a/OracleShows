#!/usr/bin/ksh

# ENV
#=================================================================
SetEnv () {

export ORACLE_SID=imlp
export ORACLE_HOME=`grep imlp /etc/oratab | awk -F: '{print $2}'`
export SQLPLUS=${ORACLE_HOME}/bin/sqlplus
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:/usr/openwin/lib:/usr/local/lib
export ORACLE_ADM=/oracle/admin/${ORACLE_SID}
export COMP=`hostname`
export ORACLE_MON=/netapp/shows/dbmon
}

# LOCK
#==================================================================
OracleCheck_Lock () {
echo "`date` - OracleCheck - Locks"

TMP_ORACLE=`$SQLPLUS -s / << *EOF*
set pages 0 echo off feedback off verify off serverout on
DECLARE
   sid1                 NUMBER;
   sid2                 NUMBER;
   countsid             NUMBER;
BEGIN
   SELECT a.sid asid, b.sid bsid, count(*) INTO sid1,sid2,countsid
   FROM v\\$lock a , v\\$lock b
   WHERE a.id1=b.id1
   AND   a.id2=b.id2
   AND   a.request=0
   AND   b.lmode=0
   GROUP BY a.sid,b.sid
   HAVING COUNT(*) > 0 ;
   DBMS_OUTPUT.PUT_LINE(countsid);
EXCEPTION
        WHEN    NO_DATA_FOUND   THEN
                DBMS_OUTPUT.PUT_LINE('0');

        WHEN	OTHERS THEN
        	DBMS_OUTPUT.PUT_LINE('99');
end;
/
*EOF*
`
# If lock sleep 60sec. and re-check
# ------------------------------------------------------
if [ ${TMP_ORACLE} -gt 0 ] ; then
sleep 60
TMP_ORACLE=`$SQLPLUS -s / << *EOF*
set pages 0 echo off feedback off verify off serverout on
DECLARE
   sid1                 NUMBER;
   sid2                 NUMBER;
   countsid             NUMBER;
BEGIN
   SELECT a.sid asid, b.sid bsid, count(*) INTO sid1,sid2,countsid
   FROM v\\$lock a , v\\$lock b
   WHERE a.id1=b.id1
   AND   a.id2=b.id2
   AND   a.request=0
   AND   b.lmode=0
   GROUP BY a.sid,b.sid
   HAVING COUNT(*) > 0 ;
   DBMS_OUTPUT.PUT_LINE(countsid);
EXCEPTION
        WHEN    NO_DATA_FOUND   THEN
                DBMS_OUTPUT.PUT_LINE('0');

        WHEN 	OTHERS THEN
        	DBMS_OUTPUT.PUT_LINE('99');
end;
/
*EOF*
`

# The killing
# ---------------------------------------------------------
if [ ${TMP_ORACLE} -gt 0 ] ; then
$SQLPLUS -s / << *EOF*
set pages 0 echo off feedback off verify off serverout on

DECLARE
   v_sid                NUMBER;
   v_serial             NUMBER;
   v_username           VARCHAR2(30);

   CURSOR lock_cur IS
        SELECT a.sid locking, b.sid locked
        FROM   v\\$lock a , v\\$lock b
        WHERE  a.id1=b.id1
        AND    a.id2=b.id2
        AND    a.request=0
        AND    b.lmode=0;

BEGIN
   FOR rec_lock IN lock_cur
   LOOP
      SELECT serial#, username INTO v_serial, v_username
      FROM   v$session
      WHERE  sid = rec_lock.locking;

      IF v_username = 'IMUSER'
      THEN
         v_sid := rec_lock.locking;
         EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION '''||v_sid||','||v_serial||'''';
         DBMS_OUTPUT.PUT_LINE('USER: '||v_username||', SID: '||v_sid||', Serial: '||v_serial);
      END IF;
   END LOOP;

EXCEPTION
        WHEN    NO_DATA_FOUND   THEN
                DBMS_OUTPUT.PUT_LINE(SYSDATE||' - NO data found!!!');
		DBMS_OUTPUT.PUT_LINE(sqlerrm);

        WHEN    OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(SYSDATE||' - Other ERROR');
		DBMS_OUTPUT.PUT_LINE(sqlerrm);
END;
/
*EOF*
fi
fi
}

# RECOMPILE
# ======================================================================
recompile () {

$SQLPLUS -s / << *EOF*
rem *
rem * generate ALTERs to recompile all invalid server PL/SQL objects
rem *
set echo off
set heading off
spool /tmp/alter1.sql
select 'alter '||object_type||' '||owner||'.'||object_name||' compile;'
  from dba_objects where owner = 'IMPROC' and status = 'INVALID' and
 (object_type = 'PROCEDURE' or
  object_type = 'FUNCTION' or
  object_type = 'TRIGGER');
select 'alter package '||' '||owner||'.'||object_name||' compile;'
  from dba_objects where owner = 'IMPROC' and status = 'INVALID' and
  object_type like '%PACKAGE%';
spool off
rem *
rem * execute  ALTERs to recompile all invalid server PL/SQL objects
rem *
set echo off
set heading off
@/tmp/alter1.sql
*EOF*
}

# MAIN
#=================================================================
SetEnv

OracleCheck_Lock

OracleCheck_Lock

recompile
recompile
recompile
recompile
recompile
