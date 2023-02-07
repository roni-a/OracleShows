#!/bin/bash 

#-----------------------------------------------------
# Usage
#-----------------------------------------------------
Usage () {

   printf '\n USAGE:	run_sheck.sh ORACLE_SID [ del | add | <sid> | -m ]\n'
   printf '\n\t del|add <sid>'
   printf '\n\t <sid> [<MAIL_LIST>]'
   printf '\n\t -m <sid> <Checks>'
   printf '\n\n\t Possible Checks:'
   printf '\n\t ----------------'
   printf '\n\t Usage'
   printf '\n\t CompDown'
   printf '\n\t DisksCheck'
   printf '\n\t NetappCheck'
   printf '\n\t StorageCheck'
   printf '\n\t InstDown'
   printf '\n\t LsnrDown'
   printf '\n\t DBConnect'
   printf '\n\t OracleCheck_TBS'
   printf '\n\t OracleCheck_Next'
   printf '\n\t OracleCheck_Lock'
   printf '\n\t OracleCheck_Rate'
   printf '\n\t OracleCheck_Invalid'
   printf '\n\t ObjSizeUpd'
   printf '\n\t AlertCheck'
   printf '\n\t RootMsgs'
   printf '\n\t SendAlive'
   printf '\n\t CheckVarBkup'
   printf '\n\t HardWere_chk'
   printf '\n\t RunCheckCtrl'
   printf '\n\t CheckMaxVer\n\n'

exit
}

#-----------------------------------------------------
# Set needed enviment variebles
#-----------------------------------------------------
SetEnv () {

export ORACLE_SID=$1 					
export ORACLE_HOME=`grep -i ${ORACLE_SID}: /etc/oratab | awk -F: '{print $2}'` 
export SQLPLUS=${ORACLE_HOME}/bin/sqlplus
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:/usr/openwin/lib:/usr/local/lib
export ORACLE_BASE=/u01/app/oracle
export ORACLE_ADM=$ORACLE_BASE/admin/${ORACLE_SID}
export OS=`uname` 
if [ "$OS" = "SunOS" ]; then
   export COMP=`hostname`
else
   export COMP=`hostname -s`
fi
export LOG_FILE=/var/oracle/run_checks/Run_check.log
export BKUP_LOG_DIR=/var/backup/
export ORACLE_MON=~/SHOWS/MON
export Status="OK"
export HOUR=`date '+%H'`
export MINUTE=`date '+%M'`
export RATE_LOOP=1
export SENDMAIL=${ORACLE_MON}/orasendmail

if [ "$MAN" != "Y" ] ; then
	echo $ORACLE_SID
	echo $ORACLE_HOME
	echo $SQLPLUS
	echo $LD_LIBRARY_PATH
	echo $ORACLE_ADM
	echo $COMP
	echo $LOG_FILE
	echo $BKUP_LOG_DIR
	echo $ORACLE_MON
	echo $Status
	echo $HOUR
	echo $MINUTE
	echo $RATE_LOOP
	echo $SENDMAIL
fi

# Cross reference check:
IS_ASM=N
case $ORACLE_SID in
   proddb) export CROSS_SIDS=dwprod 
           IS_ASM=Y
	   ;;
   dwprod) export CROSS_SIDS=proddb
	   ;;
        *) export CROSS_SIDS="" ;;
esac
}

#----------------------------------------------------
# Send any error message using postie
#----------------------------------------------------
SendMail () {
echo "`date` - Send mail"
echo $TITLE
echo $MESSAGE
   $SENDMAIL "$TITLE" "$MESSAGE" $1
}

#-----------------------------------------------------
#
#-----------------------------------------------------
CompDown () {
echo "`date` - Start CompDown"

if [ -a ${ORACLE_MON}/Checks/${CROSS_SIDS} ] ; then
   case $COMP in
      proddb1 ) CHECK_COMP="proddb2 dwdb1 dwdb2"  ;;
      proddb2 ) CHECK_COMP="proddb1 dwdb1 dwdb2"  ;;
      dwdb1   ) CHECK_COMP="proddb1 proddb2 dwdb2"  ;;
      dwdb2   ) CHECK_COMP="proddb1 proddb2 dwdb1"  ;;
      *       ) echo "UnKnown Computer ! ! !" ;;
   esac

   for CHECK_COMP_1 in `echo $CHECK_COMP`
   do
      ping -c 1 $CHECK_COMP_1 > /dev/null 2>&1

      if [ $? -ne 0 ] ; then
         if [ "$MAN" = "Y" ] ; then
            printf '\n\t %s %s %s\n\n' "`date` - " "${CHECK_COMP_1}" " id is DOWN!!!"
         else
            TITLE="${CHECK_COMP_1} id DOWN! - `date`"
            MESSAGE="${CHECK_COMP_1} id DOWN ! ! !"
            SendMail 4
         fi
      else
         if [ "$MAN" = "Y" ] ; then
	    printf '\n\t %s %s %s\n\n' "`date` - " "${CHECK_COMP_1}" " id is UP!!!"
         fi
      fi
    done
fi
}

#-----------------------------------------------------
# Check for Disk space problems
#-----------------------------------------------------
DisksCheck () {
echo "`date` - Start DisksCheck"

if [ -f /etc/fstab ]; then
   STAB=/etc/fstab
elif [ -f /etc/stab ]; then
   STAB=/etc/stab
elif [ -f /etc/vfstab ]; then
   STAB=/etc/vfstab
else
   STAB=X
fi

for DISKCHECK in `cat $STAB |egrep -v "^#|^none|swap|nfs" | tr '-' ' ' | awk '{print $2}' | egrep -v "^\/sys |^\/proc|^\/dev\/pts|\/d0"`
do
#   PST=`df -Pk $DISKCHECK | grep -v ^Filesystem | awk '{print $5}' | cut -d% -f1`
   PST=`df -k $DISKCHECK | grep -v "^Filesystem" | awk '(NF<5){f=$1; next} (NF>5){f=$1} {print $5}' | cut -d% -f1` 

   if [ $PST -ge 94 ] ; then
      case $MAN in
        Y ) printf '\n%s\n\n' "ERROR: Filesystem $DISKCHECK is ${PST}% Full!!!" ;;
        * ) echo "Filesystem $DISKCHECK is ${PST}% Full!!!"
            export TITLE="DisksCheck `date` - $COMP - Filesystem $DISKCHECK is ${PST}% Full!!!"
            export MESSAGE="FileSytem $DISKCHECK is ${PST}% Full -- CHECK!!!"
            SendMail 3 ;;
      esac
   else
      case $MAN in
        Y ) if [ $PST -le 94 ] ; then
	       printf '%s%s\t\t\t%s\n' "    " "Filesystem $DISKCHECK" " ${PST}% Full" 
	    else
	       printf '%s%s\t\t\t%s\n' "ERR " "Filesystem $DISKCHECK" " ${PST}% Full" 
	       printf '%s\n'	       "--- ---------- --------------------------"
	    fi ;;
      esac
   fi
done

if [ "$IS_ASM" = "Y" ]; then
. ~/set_asm
   for ASM_DG in `asmcmd ls | awk -F\/ '{print $1}'`
   do
      PST=`asmcmd lsdg $ASM_DG | grep -v ^State | awk '{print int(100-($8/$7*100))}'`

      if [ $PST -ge 94 ] ; then
         case $MAN in
           Y ) printf '\n%s\n\n' "ERROR: Filesystem $ASM_DG is ${PST}% Full!!!" ;;
           * ) echo "ASM Disk Group $ASM_DG is ${PST}% Full!!!"
               export TITLE="ASM Disk Group `date` - $COMP - Filesystem $ASM_DG is ${PST}% Full!!!"
               export MESSAGE="ASM Disk Group $ASM_DG is ${PST}% Full -- CHECK!!!"
               SendMail 3 ;;
         esac
      else
         case $MAN in
           Y ) if [ $PST -le 94 ] ; then
                  printf '%s%s\t\t\t%s\n' "    " "ASM Disk Group $ASM_DG" " ${PST}% Full"
               else
                  printf '%s%s\t\t\t%s\n' "ERR " "ASM Disk Group $ASM_DG" " ${PST}% Full"
                  printf '%s\n'           "--- ---------- --------------------------"
               fi ;;
         esac
      fi
   done
fi
}

#-----------------------------------------------------
# Check for Disk space problems
#-----------------------------------------------------
NetappCheck () {
if [ "$MAN" = "Y" ]; then
   echo -en "\n\t===================\n\tNetapp Spase Report\n\t===================\n\n"
else
   echo -en "\n`date` - Start NetappCheck\n\n"
fi

if [ -f /etc/fstab ]; then
   STAB=/etc/fstab
elif [ -f /etc/stab ]; then
   STAB=/etc/stab
elif [ -f /etc/vfstab ]; then
   STAB=/etc/vfstab
else
   STAB=X
fi

if [ "$STAB" != "X" ]; then
   for NETAPP in `cat $STAB | egrep -v "^#" | egrep "nfs" | egrep "filer" | tr '-' ' ' | awk '{print $3}'`
   do
      PST=`df -k $NETAPP | grep -v "^Filesystem" | awk '(NF<5){f=$1; next} (NF>5){f=$1} {print $5}' | cut -d% -f1`

#   SNAP_NO=`rsh -l root netapp snap list | grep 'incredimail\.' | wc -l`
   if [ -d ${NETAPP}/.snapshot ] ; then
      SNAP_NO=`ls ${NETAPP}/.snapshot | wc -l`
   else
      SNAP_NO=0
   fi

      if [ $PST -ge 78 ] ; then
      case $MAN in
         Y ) echo -en "\n\nERROR - NetApp - SPACE problem - ${NETAPP} - is ${PST}% full!!!\n" ;;
         * ) TITLE="ERROR - NetApp SPACE problem `date` - $COMP - ${NETAPP} - ${PST}%"
             MESSAGE="FileSytem ${NETAPP} is ${PST}% full No. of snaps: ${SNAP_NO}."
             SendMail 1 ;;
      esac
      elif [ $SNAP_NO -gt 5 -a $PST -ge 93 ] ; then
         case $MAN in
            Y ) echo -en "\n\nERROR - NetApp ($NETAPP) - NO of Snaps - ${SNAP_NO} \n" ;;
            * ) TITLE="NETAPP NO of Snaps problem `date` - $COMP - No. of snaps: ${SNAP_NO}"
                MESSAGE="FileSytem /netapp is ${PST}% full, No. of snaps: ${SNAP_NO}"
                SendMail 3 ;;
         esac
      else
         case $MAN in
            Y ) echo -en "\nVolume: ($NETAPP) is ${PST}% full = OK" ;;
         esac
      fi
   done
else
   TITLE="`date` - $COMP - can't find FSTAB"
   MESSAGE="/etc/fstab does not exist"
   if [ "$MAN" = "Y" ]; then
      echo -en "\n\n$TITLE\n$MESSAGE\n\n"
   else
      SendMail 3
   fi  
fi

if [ "$MAN" = "Y" ]; then
   echo -en "\n\n"
fi
}

#-----------------------------------------------------
# Check for Disk space problems
#-----------------------------------------------------
StorageCheck () {
if [ "$MAN" = "Y" ]; then
   echo -en "\n\t====================\n\tStorage Spase Report\n\t====================\n\n"
else
   echo -en "\n`date` - Start StorageCheck\n\n"
fi

if [ -f /etc/fstab ]; then
   STAB=/etc/fstab
elif [ -f /etc/stab ]; then
   STAB=/etc/stab
elif [ -f /etc/vfstab ]; then
   STAB=/etc/vfstab
else
   STAB=X
fi

if [ "$STAB" != "X" ]; then
   for STORAGE in `cat $STAB | egrep -v "^#|filer" | egrep "nfs" | tr '-' ' ' | awk '{print $2}'`
   do
      PST=`df -k $STORAGE | grep -v "^Filesystem" | awk '(NF<5){f=$1; next} (NF>5){f=$1} {print $5}' | cut -d% -f1`

      if [ $PST -ge 95 ] ; then
         case $MAN in
            Y ) echo -en "\nERROR - Storage - SPACE problem - ${STORAGE} - ${PST}% \n" ;;
            * ) TITLE="ERROR - Storage  SPACE problem `date` - $COMP - ${STORAGE} - ${PST}%"
                MESSAGE="FileSytem ${STORAGE} is ${PST}% full."
                SendMail 1 ;;
         esac
      else
         case $MAN in
            Y ) echo -en "\nSTORAGE: ($STORAGE) is ${PST}% full = OK" ;;
         esac
      fi
   done
else
   TITLE="`date` - $COMP - can't find FSTAB"
   MESSAGE="/etc/fstab does not exist"
   if [ "$MAN" = "Y" ]; then
      echo -en "\n\n$TITLE\n$MESSAGE\n\n"
   else
      SendMail 3
   fi
fi
if [ "$MAN" = "Y" ]; then
   echo -en "\n\n"
fi
}

#-----------------------------------------------------
# Check if the oracle instace is up
#-----------------------------------------------------
InstDown () {
echo "`date` - Start InstDown"

ps -ef | grep pmon | grep -i $ORACLE_SID > /dev/null 2>&1

if [ $? -ne 0 ] ; then
   DB_UP=`echo "show user" | $SQLPLUS -s / | awk '{print $1}'`

   if [ "X${DB_UP}" != "XUSER" ] ; then
#         echo "URGENT ! ! ! -- $COMP - $ORACLE_SID is DOWN ! ! !"
      Status="Fail"
      TITLE="InstDown `date` - URGENT ! ! ! -- $COMP - $ORACLE_SID is DOWN ! ! !"
      MESSAGE="Oracle Instance: ---- $ORACLE_SID  ---- IS Down !! !! !!"
      SendMail 4
   fi
else
   case $MAN in
      Y ) echo -en "\nIstanse: $COMP - $ORACLE_SID is UP - OK ;)\n" ;;
   esac
fi

# Cross Instance Checking:
for SID in $CROSS_SIDS
do
   if [ -a ${ORACLE_MON}/Checks/${CROSS_SIDS} ]; then
      DB_UP=`eval echo "show user" | eval $SQLPLUS -s roni/Matan97@${SID} | awk '{print $1}'`

      if [ "X${DB_UP}" != "XUSER" ] ; then
         echo "URGENT ! ! ! - UnAble to connect to: $SID ! ! !"
         TITLE="InstDown `date` - URGENT ! ! ! - UnAble to connect to: $SID ! ! !"
         MESSAGE="No connection to: ---- $SID  ----  !! !! !!"
         SendMail 4
      else
         case $MAN in
            Y ) echo -en "\nIstanse: $SID is UP - OK ;)\n"
         esac
      fi
   fi
done
if [ "$MAN" = "Y" ]; then
   echo -en "\n\n"
fi
}

#-----------------------------------------------------
# Check if the Listener is up
#-----------------------------------------------------
LsnrDown () {
echo "`date` - LsnrDown"

   $ORACLE_HOME/bin/lsnrctl stat > /dev/null 2>&1

   if [ $? -ne 0 ] ; then
      TITLE="LsnrDown  `date` - URGENT ! ! ! -- $COMP - Listener for: $ORACLE_SID is DOWN ! ! !"
      MESSAGE="The Listener of: ---- $ORACLE_SID  ---- IS Down !! !! !!"
      if [ "$MAN" = "Y" ]; then
         echo -en "\n$TITLE\n$MESSAGE\n\n"
      else
         SendMail 3
      fi
   elif [ "$MAN" = "Y" ]; then
      echo -en "\nListener of: ---- $ORACLE_SID  ---- IS UP ;)\n\n"
   fi
}

#-----------------------------------------------------
# Check  Connection to db
#-----------------------------------------------------
DBConnect () {
echo "`date` - DBConnect"

DB_UP=`echo "show user" | $SQLPLUS -s roni/matan97@${ORACLE_SID} | awk '{print $1}'`

if [ "X${DB_UP}" != "XUSER" ] ; then
   TITLE="DBConnect `date` - URGENT ! ! ! -- $COMP - UnAble to connect to: $ORACLE_SID by Listner"
   MESSAGE="No connection to: ---- $ORACLE_SID  ----  !! !! !!"
   if [ "$MAN" = "Y" ]; then
      echo -en "\n$TITLE\n$MESSAGE\n\n"
   else
      SendMail 4
   fi
elif [ "$MAN" = "Y" ]; then
    echo -en "\nConnection to $ORACLE_SID using Listner is OK\n\n"
fi
}

#-----------------------------------------------------
# Oracle checks:
#	1. Table space problems
#	2. Next extent problems
#	3. Locks
#	4. Commit rate
#-----------------------------------------------------
#-----------------------------------------------------
# Check TBS space
#-----------------------------------------------------
OracleCheck_TBS () {
echo "`date` - OracleCheck - TBS"
if [ "$OS" = "SunOS" ]; then
. ~/.profile
else
. ~/.bash_profile
fi
TMP_ORACLE=`$SQLPLUS -s / << *EOF*
set pages 0 feed off echo off verify off lines 140
SELECT RPAD(d.tablespace_name,40,'_')||NVL(ROUND(f.bytes/a.bytes*100,0),0)||'%'||chr(13)
  FROM sys.dba_tablespaces d,
       (SELECT   tablespace_name, SUM(bytes) bytes
            FROM dba_data_files
        GROUP BY tablespace_name) a,
       (SELECT   tablespace_name, SUM(bytes) bytes
            FROM dba_free_space
        GROUP BY tablespace_name) f,
       (SELECT   tablespace_name, MAX(bytes) large
            FROM dba_free_space
        GROUP BY tablespace_name) l
 WHERE d.tablespace_name = a.tablespace_name(+)
   AND d.tablespace_name = f.tablespace_name(+)
   AND d.tablespace_name = l.tablespace_name(+)
   AND NOT d.contents LIKE 'TEMPORARY'
   AND NVL(ROUND(f.bytes/a.bytes*100,0),0) <= 5
 ORDER BY 1
/
*EOF*
`

if [ "X${TMP_ORACLE}" != "X" ] ; then
COMP=`echo $COMP |awk -F. '{print $1}' | tr 'a-z' 'A-Z'`
   TITLE="OracleCheck_TBS - `date` - from $COMP - Tablespaces with less than 5% free space. SID = $ORACLE_SID"
   MESSAGE="${TMP_ORACLE}"
   SendMail 2
fi      

TMP_ORACLE=`$SQLPLUS -s / << *EOF*
set pages 0 feed off echo off verify off lines 140
SELECT * FROM (
SELECT * FROM (
 SELECT rownum AS rank
    FROM (SELECT NVL(ROUND(f.bytes/a.bytes*100,0),0) PCT_FREE
   FROM sys.dba_tablespaces d,
        (SELECT   tablespace_name, SUM(bytes) bytes
             FROM dba_data_files
         GROUP BY tablespace_name) a,
        (SELECT   tablespace_name, SUM(bytes) bytes
             FROM dba_free_space
         GROUP BY tablespace_name) f,
        (SELECT   tablespace_name, MAX(bytes) large
             FROM dba_free_space
         GROUP BY tablespace_name) l
  WHERE d.tablespace_name = a.tablespace_name(+)
    AND d.tablespace_name = f.tablespace_name(+)
    AND d.tablespace_name = l.tablespace_name(+)
    AND NOT d.contents LIKE 'TEMPORARY'
    AND NVL (ROUND(f.bytes/a.bytes*100,0),0) <= 1
  ORDER BY pct_free) ts)
 ORDER BY 1 DESC)
WHERE rownum = 1;
*EOF*
`
   if [ "${TMP_ORACLE}" = "" ]; then
      TMP_ORACLE=100
   elif [ ${TMP_ORACLE} -le 1 ] ; then
      TITLE="! ! ! OracleCheck_TBS - `date` - $COMP - There are $TMP_ORACLE Tablespaces with less than 1% free space in $ORACLE_SID"
      MESSAGE="${TMP_ORACLE}"
      SendMail 3
   fi
}

#----------------------------------------------------
# Oracle checks: Next Ext.
#----------------------------------------------------
OracleCheck_Next () {
echo "`date` - OracleCheck - Next Extents"
if [ "$OS" = "SunOS" ]; then
. ~/.profile
else
. ~/.bash_profile
fi
TMP_ORACLE=`$SQLPLUS -s / << *EOF*
set pages 0 feed off echo off verify off lines 200
col Tablespace for a25
col type for a8
col "Object Name" for a50
col "Required Extent(K)" for a15
col "MaxAvail K" for a15
select  b.tablespace_name "Tablespace",
        b.segment_type "Type",
        substr(ext.owner||'-'||ext.segment_name,1,50) "Object Name",
        To_Char(decode(freespace.Extent_Management,'DICTIONARY',decode(b.extents,1,b.next_extent, ext.bytes * (1+b.pct_increase/100)),'LOCAL',decode( freespace.Allocation_Type,'UNIFORM',freespace.INITIAL_EXTENT,'SYSTEM',ext.bytes))/1024,'9,999,999,999') "Required Extent(K)",
        to_char(freespace.largest/1024,'9,999,999,999') "MaxAvail K"
 from dba_segments b,
      dba_extents ext,
     (select B.tablespace_name, B.Extent_Management, B.Allocation_Type, B.INITIAL_EXTENT, B.NEXT_EXTENT, max(A.bytes) largest
      from   dba_free_space A, dba_tablespaces B
      Where B.Tablespace_Name = A.Tablespace_Name
      And B.Status='ONLINE'
      group by B.tablespace_name, B.Extent_Management, B.Allocation_Type, B.INITIAL_EXTENT, B.NEXT_EXTENT
      ) freespace
 where
        b.owner=ext.owner and
        b.segment_type=ext.segment_type and
        b.segment_name=ext.segment_name and
        b.tablespace_name= ext.tablespace_name and
        (b.extents-1) =ext.extent_id and
        b.tablespace_name = freespace.tablespace_name and
        decode(freespace.Extent_Management,'DICTIONARY',decode(b.extents,1,(b.next_extent),ext.bytes*(1+b.pct_increase/100)),'LOCAL',decode(freespace.Allocation_Type,'UNIFORM',freespace.INITIAL_EXTENT,'SYSTEM',ext.bytes)) > freespace.largest
order by b.Tablespace_Name,b.Segment_Type,b.Segment_Name
/
*EOF*
`
TMP_ORACLE=`echo ${TMP_ORACLE} | cut -d'.' -f2` 
echo $TMP_ORACLE

if [ "X${TMP_ORACLE}" != "X" ] ; then
   TITLE="OracleCheck_Next - `date` - $COMP - Objects with Next extent problems in $ORACLE_SID !"
   MESSAGE=`echo $TMP_ORACLE | sed 's/\^/\\\n/g'`
   SendMail 2
fi      
}

#----------------------------------------------------
# Oracle checks: Lock session
# rem create or replace procedure accusleep ( seconds_in number ) is
# rem    v_chunk_size constant integer := 100;
# rem    v_compensation constant number := 0.976;
# rem    v_chunks integer;
# rem    v_remainder integer;
# rem    v_seconds integer;
# rem begin
# rem    v_seconds := seconds_in * v_compensation;
# rem    v_chunks := trunc(v_seconds/v_chunk_size);
# rem    v_remainder := mod(v_seconds, v_chunk_size);
# rem 
# rem    for i in 1..v_chunks
# rem    loop
# rem       dbms_lock.sleep(v_chunk_size);
# rem    end loop;
# rem    dbms_lock.sleep(v_remainder);
# rem 
# rem    --dbms_output.put_line(v_chunks);
# rem    --dbms_output.put_line(v_remainder);
# rem end;
# rem /
#----------------------------------------------------
OracleCheck_Lock () {
echo "`date` - OracleCheck - Locks"
if [ "$OS" = "SunOS" ]; then
. ~/.profile
else
. ~/.bash_profile
fi
TMP_ORACLE=`$SQLPLUS -s / << *EOF*
set pages 0 echo off feedback off verify off serverout on
DECLARE
   countsid 		NUMBER;
BEGIN
   SELECT SUM(COUNT(*)) INTO countsid
   FROM v\\$lock a , v\\$lock b
   WHERE a.id1=b.id1
   AND   a.id2=b.id2
   AND   a.request=0
   AND   b.lmode=0
   GROUP BY a.sid,b.sid
   HAVING COUNT(*) > 0 ;
   DBMS_OUTPUT.PUT_LINE(NVL(countsid,0));
EXCEPTION
	WHEN	NO_DATA_FOUND	THEN
		DBMS_OUTPUT.PUT_LINE('0');
	WHEN	OTHERS	THEN
		DBMS_OUTPUT.PUT_LINE('99');
end;
/
*EOF*
`
echo "1. =================== TMP_ORACLE = $TMP_ORACLE ============================="
if [ ${TMP_ORACLE} -gt 0 ] ; then
sleep 15
TMP_ORACLE=`$SQLPLUS -s / << *EOF*
set pages 0 echo off feedback off verify off serverout on
DECLARE
   countsid             NUMBER;
BEGIN
   SELECT SUM(COUNT(*)) INTO countsid
   FROM v\\$lock a , v\\$lock b
   WHERE a.id1=b.id1
   AND   a.id2=b.id2
   AND   a.request=0
   AND   b.lmode=0
   GROUP BY a.sid,b.sid
   HAVING COUNT(*) > 0 ;
   DBMS_OUTPUT.PUT_LINE(NVL(countsid,0));
EXCEPTION
        WHEN    NO_DATA_FOUND   THEN
                DBMS_OUTPUT.PUT_LINE('0');
        WHEN	OTHERS	THEN
        	DBMS_OUTPUT.PUT_LINE('99');
end;
/
*EOF*
`
echo "2. =================== TMP_ORACLE = $TMP_ORACLE ============================="
   if [ ${TMP_ORACLE} -gt 0 ] ; then
      TITLE="OracleCheck_Lock  - `date` - $COMP - There are $TMP_ORACLE Session LOCKs in $ORACLE_SID !"
      MESSAGE="The number of locked session is: ${TMP_ORACLE}"
      SendMail 1
   fi
fi
}

#----------------------------------------------------
# Oracle checks: Commit rate
#----------------------------------------------------
OracleCheck_Rate () {
echo "`date` - OracleCheck - Commit Rate"
if [ "$OS" = "SunOS" ]; then
. ~/.profile
else
. ~/.bash_profile
fi
TMP_ORACLE=`$SQLPLUS -s / << *EOF*
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
   FROM   v\\$sysstat
   where STATISTIC# = 4;

accusleep(1);
   time_2 := DBMS_UTILITY.GET_TIME;
   SELECT value INTO value_2
   FROM   v\\$sysstat
   where STATISTIC# = 4;

accusleep(1);
   time_3 := DBMS_UTILITY.GET_TIME;
   SELECT value INTO value_3
   FROM   v\\$sysstat
   where STATISTIC# = 4;

DBMS_OUTPUT.PUT_LINE (ROUND((((value_2 - value_1)/(time_2 - time_1)+(value_3 - value_2)/(time_3 - time_2))/2)*100));
end;
/
*EOF*
`
TMP_ORACLE=`echo ${TMP_ORACLE} | cut -d'.' -f2`

if   [[ ${TMP_ORACLE} -ge 0 && ${TMP_ORACLE} -lt 5 && $RATE_LOOP -eq 1 ]] ; then
   export RATE_LOOP=2
   OracleCheck_Rate
elif [[ ${TMP_ORACLE} -ge 0 && ${TMP_ORACLE} -lt 5 && $RATE_LOOP -eq 2 ]] ; then
   TITLE="OracleCheck_Rate  `date` - $COMP - The Commit rate is ${TMP_ORACLE} per sec.!"
   MESSAGE="The commit rate is: ${TMP_ORACLE}"
   SendMail 3
fi
echo "--- TMP_ORACLE = $TMP_ORACLE ---- RATE_LOOP = $RATE_LOOP ---"
}

#----------------------------------------------------
# Oracle checks: Invalid Objects
#----------------------------------------------------
OracleCheck_Invalid () {
printf '%s\n\n'  "`date` - OracleCheck - Invalid Objects."
SEND_MAIL=N
if [ "$OS" = "SunOS" ]; then
. ~/.profile
else
. ~/.bash_profile
fi
TMP_ORACLE=`$SQLPLUS -s / << *EOF*
set pages 0 echo off verify off feedback    off
  SELECT owner||' - '||object_name||' - '||object_type||' - '||status||'^'
  FROM   dba_objects
  WHERE  status='UNUSABLE' OR status='INVALID'
  AND    owner NOT IN ('CTXSYS','EXFSYS','MDSYS','ORDSYS','OWNER','PUBLIC','SYS','OWNER','SYS','SYSMAN','SYSTEM','WMSYS','XDB', 'SQLTXPLAIN','DMSYS','DBSNMP','OLAPSYS')
  AND    object_type <> 'MATERIALIZED VIEW'
union all
  SELECT owner||' - '||index_name||' - '||index_type||' - '||status||'^'
  FROM   dba_indexes
  WHERE  status='UNUSABLE' OR status='INVALID'
  AND    owner NOT IN ('CTXSYS','EXFSYS','MDSYS','ORDSYS','OWNER','PUBLIC','SYS','OWNER','SYS','SYSMAN','SYSTEM','WMSYS','XDB', 'SQLTXPLAIN','DMSYS','DBSNMP', 'OLAPSYS')
/
*EOF*
`
echo ====== 2
PROC_OBJ=`$SQLPLUS -s / << *EOF*
set pages 0 echo off verify off feedback    off
  SELECT owner||' - '||object_name||' - '||object_type||' - '||status||'^'
  FROM   dba_objects
  WHERE  status='UNUSABLE' OR status='INVALID'
  AND    object_type in ('PACKAGE','PACKAGE BODY','FUNCTION')
  AND    owner NOT IN ('CTXSYS','EXFSYS','MDSYS','ORDSYS','OWNER','PUBLIC','SYS','OWNER','SYS','SYSMAN','SYSTEM','WMSYS','XDB', 'SQLTXPLAIN','DMSYS','DBSNMP', 'OLAPSYS')
/
*EOF*
`
echo ====== 3
EMP_SYN=`$SQLPLUS -s / << *EOF*
set pages 0 echo off verify off feedback    off
Select OWNER||'.'||s.synonym_name||' - '||s.TABLE_OWNER||' - '||s.TABLE_NAME||'^'
From dba_synonyms  s
Where table_owner not in('SYSTEM','SYS')
And OWNER not in ('PUBLIC')
And db_link is null
And not exists
     (select  1
      From dba_objects o
      Where s.table_owner=o.owner
      And s.table_name=o.object_name)
 Order by 1
/
*EOF*
`

case $1 in
   -m ) TMP_ORACLE=`echo -en $TMP_ORACLE | sed 's/\^/\\\n/g'`
	      PROC_OBJ=`echo -en $PROC_OBJ | sed 's/\^/\\\n/g'`
 	      EMP_SYN=`echo $EMP_SYN | sed 's/\^/\\\n/g'`
	      echo -en "\n$TMP_ORACLE\n"
	      echo -en "\n$PROC_OBJ\n"
	      echo -en "\n$EMP_SYN\n"
 	      ;;
    * ) if [ "X${TMP_ORACLE}" != "X" ] ; then
	         SEND_MAIL=Y
	      fi
	      if [ "X${PROC_OBJ}" != "X" ] ; then
	         . ${ORACLE_MON}/recomp_invalid.sh $ORACLE_SID > /var/oracle/invalid/recomp_invalid.log.$$ 2>&1 & 
	         SEND_MAIL=Y
	      fi
	      if [ "X${EMP_SYN}" != "X" ] ; then
	         SEND_MAIL=Y
        fi
	      if [ "$SEND_MAIL" = "Y" ] ; then
   	       TITLE="OracleCheck_Invalid `date` - $COMP - There are invalid OBJECTS in $ORACLE_SID"
   	       MESSAGE1=`echo $TMP_ORACLE | sed 's/\^/\\\n/g'`
	         MESSAGE2=`echo -en $PROC_OBJ | sed 's/\^/\\\n/g'`
	         MESSAGE3=`echo $EMP_SYN | sed 's/\^/\\\n/g'`
	         MESSAGE="$MESSAGE1 $MESSAGE2 $MESSAGE3"
   	       SendMail 1
	      fi
	      ;;
esac
}

#----------------------------------------------------
#
#----------------------------------------------------
CheckMaxVer () {
echo "`date` - CheckMaxVer"
if [ "$OS" = "SunOS" ]; then
. ~/.profile
else
. ~/.bash_profile
fi
TMP_ORACLE=`$SQLPLUS -s / << *EOF*
set pages 0 echo off verify off feedback off
select max(count(*))  v
from   sys.x_\\$kglcursor
where  inst_id = userenv('Instance') 
and    kglhdadr != kglhdpar
group  by kglhdpar, kglnahsh
/
*EOF*
`
TMP_ORACLE=`echo ${TMP_ORACLE} | cut -d'.' -f2`
echo "MaxVer = ${TMP_ORACLE}"

if [ ${TMP_ORACLE} -gt 30 ] ; then
$SQLPLUS -s /nolog << *EOF*
conn system/canbara
alter system flush shared_pool
/
*EOF*

#   TITLE="CheckMaxVer `date` - Max SQL Cursor ver. is ${TMP_ORACLE}"
#   MESSAGE="Shared pool was flushed!"
#   SendMail 4
fi
}

#----------------------------------------------------
# Update Object size table
#----------------------------------------------------
ObjSizeUpd () {
echo "`date` - ObjSizeUpd."
# CREATE TABLE monitor_seg_size(owner_name varchar2(30), segment_name varchar2(35), segment_type  varchar2(30), seg_size_mb number, report_date date);
if [ "$OS" = "SunOS" ]; then
. ~/.profile
fi
$SQLPLUS -s /   << *EOF*
set pages 0 echo off verify off feedback    off
set serverout on size 1000000
INSERT INTO monitor_seg_size
        SELECT owner, segment_name, segment_type, ROUND(sum(bytes/1024/1024),2) MB, trunc(sysdate)
        FROM   dba_segments
        WHERE (segment_type = 'INDEX' or segment_type = 'TABLE' or segment_type = 'TABLE PARTITION' or segment_type = 'INDEX PARTITION')
        AND owner NOT IN ('CTXSYS','EXFSYS','MDSYS','ORDSYS','OWNER','PUBLIC','SYS','OWNER','SYS','SYSMAN','SYSTEM','WMSYS','XDB', 'SQLTXPLAIN','DMSYS','DBSNMP', 'OLAPSYS')
        GROUP BY owner, segment_name, segment_type
        ORDER BY 1,2,3;

COMMIT;
*EOF*
}

#----------------------------------------------------
# Oracle alert file check
#----------------------------------------------------
AlertCheck () {
echo "`date` - AlertCheck"

ALRT_FILE=${ORACLE_ADM}/bdump/alert_${ORACLE_SID}.log
ALRT_FILE_HIST=${ORACLE_ADM}/bdump/history_alert_${ORACLE_SID}.log

\egrep "ORA-1653|ORA-1654|error 19502|Archiving not possible" ${ALRT_FILE}
if [ $? -eq 0 ] ; then
   TITLE="$ORACLE_SID: Critical Error! -  `date`"
   MESSAGE="See alert file history! Possible Errors: ORA-1653, ORA-1654, error 19502 ,Archiving not possible"
   SendMail 3
   cat   ${ALRT_FILE}  >> ${ALRT_FILE_HIST}
   \rm ${ALRT_FILE}
   touch ${ALRT_FILE}
else
   ALERTS=`\egrep "ORA-|^Errors" ${ALRT_FILE}`

   if [ "X${ALERTS}" != "X" ] ; then
      TITLE="AlertCheck `date` - Errors in Alert file for instance: $ORACLE_SID"
      MESSAGE="$ALERTS"
      SendMail 1
      cat   ${ALRT_FILE} 	>> ${ALRT_FILE_HIST}
      \rm ${ALRT_FILE}
      touch ${ALRT_FILE}
   fi
fi
}

#----------------------------------------------------
# Root error message check once a day
#----------------------------------------------------
RootMsgs () {
echo "`date` - RootMsgs"

   ROOT_MSGS=`cat /var/log/messages | egrep -v "running psvc_fan_fault_check_policy_0|daemon.error] I/O error|sendmail|last message repeated" | cut -f4- -d' ' | sort -u`

   if [ "X${ROOT_MSGS}" != "X" ] ; then
      TITLE="RootMsgs    `date` - ROOT Alerts for HOST: $ORACLE_SID "
      MESSAGE="$ROOT_MSGS"
      SendMail 1
   fi
}

#----------------------------------------------------
# Send is alive 
#----------------------------------------------------
SendAlive () {
echo "`date` - SendAlive"

   TITLE="SendAlive  `date` - Send Alive"
   MESSAGE="The check proccess can send mail."
   SendMail 1
}

#----------------------------------------------------
# Oracle Backup Logs Check
#----------------------------------------------------
CheckVarBkup () {
echo "`date` - Check Backups"

cd $BKUP_LOG_DIR

ls DB_backup_arch.* > /dev/null 2>&1
if [ $? -eq 0 ] ; then
   for BK_LOG_FILE in `find . -mtime 0 -name "DB_backup_arch.*" | tail -2`
   do
      /usr/bin/grep "RMAN-00569" $BK_LOG_FILE > /dev/null 2>&1
      if [ $? -eq 0 ] ; then
         TITLE="Arch Bkup `date` - Archive Backup error in file: $BK_LOG_FILE"
         MESSAGE="egrep "fatal error|error encountered|error running|ORACLE error" $BK_LOG_FILE"
         SendMail 1
      fi
   done
fi

ls DB_hot_backup_lvl* > /dev/null 2>&1
if [ $? -eq 0 ] ; then
   for BK_LOG_FILE in `find . -mtime 0 -name "DB_hot_backup_lvl*" | tail -2`
   do
      /usr/bin/grep "ERROR MESSAGE STACK FOLLOWS" $BK_LOG_FILE > /dev/null 2>&1
      if [ $? -eq 0 ] ; then
         TITLE="Hot Bkup `date` - Hot Backup error in file: $BK_LOG_FILE"
         MESSAGE=`egrep "fatal error|error encountered|error running|ORACLE error" $BK_LOG_FILE`
         SendMail 1
      fi
   done
fi
}

#----------------------------------------------------
# 
#----------------------------------------------------
HardWere_chk () {
echo "`date` - HardWere_chk"

FREEMEM=`free | grep '\-\/+' | awk '{print $4}'`

if [ $FREEMEM -lt 1000000 ] ; then
   case $MAN in
      Y  ) echo "`date` - ERROR: Free Memory on Noosa is: $FREEMEM" ;;
      *  ) TITLE="`date` - ERROR: Free Memory on Noosa is: $FREEMEM"
   	   MESSAGE="Check free memory on Noosa"
   	   SendMail 1 ;;
   esac
elif [ "$MAN" = "Y" ] ; then
   echo "`date` - Free Memory on Noosa is: $FREEMEM"
fi

}

#----------------------------------------------------
# 
#----------------------------------------------------
RunCheckCtrl () {
echo "`date` - RunCheckCtrl Start $1 $2"
case $1 in
   del ) if [ -f ${ORACLE_MON}/Checks/${ORACLE_SID} ] ; then
	    echo "`date` - Delete ${ORACLE_SID}" >> ${ORACLE_MON}/Checks/AddDel.log
	    \rm -f ${ORACLE_MON}/Checks/${ORACLE_SID}
	 fi ;;
   add ) if [ ! -a ${ORACLE_MON}/Checks/${ORACLE_SID} ] ; then
	    echo "`date` - Add ${ORACLE_SID}" >> ${ORACLE_MON}/Checks/AddDel.log
	    touch ${ORACLE_MON}/Checks/${ORACLE_SID}
	 fi ;;
esac
}

#----------------------------------------------------
# M A I N
#----------------------------------------------------

if [ $# -eq 0 ] ; then
   Usage
   exit
fi

case $1 in
         del|add ) SetEnv $2
	                 RunCheckCtrl $1 $2
	                 exit 
	                 ;;
   proddb|dwprod ) SetEnv $1 
	                 echo "============================== Start - `date` ============================"
	                 export TO_RUN=0
	                 if [ $# -eq 2 ] ; then
   		                export SEND_MAIL=$2
		                  export TO_RUN=0
	                 elif  [ $# -eq 3 ] ; then
   		                export SEND_MAIL=$2
		                  export TO_RUN=$3
	                 elif  [ $# -eq 4 ] ; then
   		                export SEND_MAIL=$4
	                 fi 
	                 ;;
              -m ) if [ $# -ne 3 ] ; then
                      Usage
 	                 else
		                  export MAN=Y
	                    SetEnv $2
                      $3 $1 
	                 fi
	                 exit 
	                 ;;
               * ) printf '\n\t%s'   "-----------------------------------------------------------------------"
	                 printf '\n%s'     "! ! ! ! Run_Check - Wronge Comman line argument. - `date` ! ! ! !"
 	                 printf '\n\t%s\n' "-----------------------------------------------------------------------"
	                 Usage
	                 exit 
	                 ;;
esac

if [ -a ${ORACLE_MON}/Checks/${ORACLE_SID} ] ; then

   if [ ! -f $LOG_FILE ] ; then
      touch $LOG_FILE
   fi

   echo "`date` - Start checking"

# -- Checks that runs every time ---------------------------------------- #
  if [ "X${ORACLE_SID}" != "X" ] ; then
     CompDown
     DisksCheck
     InstDown
     # HardWere_chk
  else
     echo "`date` - No main DB"
  fi
  if [ "X${Status}" = "XOK" ] ; then
     if [ "X${ORACLE_SID}" != "X" ] ; then
        LsnrDown
        DBConnect
        # AlertCheck
     fi
# -- Checks that runs every 15Min. ---------------------------------------- #
     echo TO_RUN = $TO_RUN for every 15Min
     if [ $TO_RUN -eq 15 ] ; then
        echo "In every 15Min."
	      OracleCheck_Lock
  	    if [ "X${ORACLE_SID}" != "X" ] ; then
           OracleCheck_Rate
   	    fi
     fi
# -- Checks that runs every HOUR ---------------------------------------- #
     echo TO_RUN = $TO_RUN for Every 60 Min
     if [ $TO_RUN -eq 60 ] ; then
        echo "Run Every 60 Min."
        NetappCheck
	      StorageCheck
        # OracleCheck_TBS
        # OracleCheck_Next
	      # OracleCheck_Invalid
	      # CheckMaxVer
	      # AlertCheck
     fi
# -- Checks that runs ONCE A DAY ---------------------------------------- #
     echo TO_RUN = $TO_RUN for Once A Day
     if [ $TO_RUN -eq 1 ] ; then
        echo "Run Once A Day!"
        SendAlive
        # OracleCheck_Invalid
   	    if [ "X${ORACLE_SID}" != "X" ] ; then
   	       ObjSizeUpd
   	    fi
        # RootMsgs
        # CheckVarBkup
     fi
  fi

  echo "`date` - End Checking"
fi

