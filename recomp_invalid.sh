#!/usr/bin/ksh

# Usage
# ---------------------------------------------------------------------
Usage () {
   echo "\n\tUsage: recomp_invalid.sh <SID>\n"
   exit
}

# ENV
# ---------------------------------------------------------------------
SetEnv () {
echo "============== `date` - Start SetEnv. \n"

export ORACLE_SID=$1							 ; echo $ORACLE_SID
export ORACLE_HOME=`grep $ORACLE_SID /etc/oratab | awk -F: '{print $2}'` ; echo $ORACLE_HOME
export SQLPLUS=${ORACLE_HOME}/bin/sqlplus				 ; echo $SQLPLUS
export LSNR=${ORACLE_HOME}/bin/lsnrctl					 ; echo $LSNR
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:/usr/openwin/lib:/usr/local/lib
export ORACLE_ADM=/oracle/admin/${ORACLE_SID}				 ; echo $ORACLE_ADM
export COMP=`hostname`							 ; echo $COMP
export ORACLE_MON=/netapp/shows/dbmon
export RUNCHECK=${ORACLE_MON}/run_check.sh
export LOGDIR=/var/oracle/invalid

if [ -f ${LOGDIR}/recomp_running ] ; then
   echo "============== `date` - recompile of invalid procedure is already running!"
   exit
else
   touch ${LOGDIR}/recomp_running
fi
}

# Send any error message using postie
#----------------------------------------------------
SendMail () {
echo "============== `date` - Send mail"
   /netapp/shows/dbmon/orasendmail "$TITLE" "$MESSAGE" 8
}

# KillIT
# ---------------------------------------------------------------------
killit () {
echo "============== `date` - Start killit. \n"

if [ "${1}" = "web" ] ; then
KILL_LOG=`/oracle/product/8.1.7/bin/sqlplus -s / << *EOF*
set pages 0 feed off echo off verify off lines 140
SELECT sid||','||serial#
  FROM v\\$session
 WHERE username = 'IMUSER';
*EOF*
`
else
KILL_LOG=`/oracle/product/8.1.7/bin/sqlplus -s / << *EOF*
set pages 0 feed off echo off verify off lines 140
SELECT sid||','||serial#
  FROM v\\$session
 WHERE username = 'IMUSER';
*EOF*
`
fi

for SES in $KILL_LOG
do
echo About to kill $SES
$SQLPLUS -s / << *EOF*
ALTER SYSTEM KILL SESSION '${SES}';
*EOF*
done

}

# RECOMPILE
# ---------------------------------------------------------------------
recompile () {
echo "============== `date` - Start recompile. \n"

$SQLPLUS -s / << *EOF*
rem *
rem * generate ALTERs to recompile all invalid server PL/SQL objects
rem *
set echo off
set heading off
spool /tmp/alter1.sql
select 'alter '||object_type||' '||owner||'.'||object_name||' compile;'
  from dba_objects where owner IN ('IMPROC','DW_SCHEMA') 
  and status = 'INVALID' and
 (object_type = 'PROCEDURE' or
  object_type = 'FUNCTION' or
  object_type = 'TRIGGER');
select 'alter package '||' '||owner||'.'||object_name||' compile;'
  from dba_objects where owner IN ('IMPROC','DW_SCHEMA')
  and status = 'INVALID' and
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

# Check Invalid
# ---------------------------------------------------------------------------------
OracleCheck_Invalid () {
echo "============== `date` - Check Invalid Objects.\n"

PROC_OBJ=`$SQLPLUS -s / << *EOF*
set pages 0 echo off verify off feedback    off
  SELECT owner||' - '||object_name||' - '||object_type||' - '||status||'^'
  FROM   dba_objects
  WHERE  status='UNUSABLE' OR status='INVALID'
  AND    object_type in ('PACKAGE','PACKAGE BODY','FUNCTION')
  AND    (owner = 'IMPROC' or owner = 'DW_SCHEMA')
/
*EOF*
`
}

# MAIN
#=================================================================
if [ $# -lt 1 ] ; then
    Usage
fi

TITLE="ReComp - `date` - was activated!"
MESSAGE="Check Invalids !!!"
SendMail

echo "============== `date` - RECOMPILE Invalid Obgects Start for: $1 . \n"
SetEnv $1

if [ $# -eq 2 ] ; then
   killit $2
else
   killit
fi

recompile
recompile
recompile
recompile
recompile

OracleCheck_Invalid

if [ "X${PROC_OBJ}" != "X" ] ; then
echo "Start second Recompile proc."
echo "============== Stop $ORACLE_SID Checks ===================="
   $RUNCHECK del $ORACLE_SID
echo "============== LSNR DOWN =================================="
#   $LSNR stop
   killit

   recompile
   recompile
   recompile
   recompile
   recompile

echo "============== LSNR UP =================================="
#   $LSNR star
echo "============== Start $ORACLE_SID Checks ===================="
   $RUNCHECK add $ORACLE_SID
fi

\rm -f ${LOGDIR}/recomp_running

TITLE="ReComp - `date` - was activated!"
MESSAGE="Check Invalids !!!"
SendMail
 
echo "`date` - End of Rcompile"
