#!/bin/sh

######################################################################
# Script:    send_xls
# Author:    Nirit Le. Amdocs
# Date:      04/02
# Update:
#
#######################################################################
# Script Purpose: Sending script output as an eXcel file
# Script Parameters:
# SQL Scripts: 
#######################################################################
# Assumptions:
#######################################################################

OK=0
ERROR=1

Log_Dir=$ORACLE_MON/logs/dbmon
Sql_Dir=$ORACLE_MON/sqls

#########################################################################
# Print script usage
#
Usage()
{
 printf "\n\n\n"
 echo "Usage: { `basename $0` mail_recipient script_to_run }"
 printf "\n\n"
}

#########################################################################
# MAIN
#

 Log=$Log_Dir/send_xls_$$.log
 cp /dev/null $Log

 Recip=$1
 shift
 Subject=`echo $1$2 | cut -d. -f1`

 $* | tee /tmp/send_xls_$$.log 
 cat /tmp/send_xls_$$.log | tr -s ' ', '\t' > $Log 

 if [ `uname` = 'HP-UX' ]
   then Flag="-m"
   else Flag=""
 fi
 uuencode $Log $Subject.xls | mailx -s "$Subject" $Flag $Recip

