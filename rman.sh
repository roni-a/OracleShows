#!/bin/ksh

#---------------------------------------------------
# USAGE
#---------------------------------------------------
Usage () {
   exit
}

#---------------------------------------------------
#
#---------------------------------------------------
ShowRman () {

sqlplus -s / << *EOF*

set lines 200;

alter session set nls_date_format = 'DD-MON-YYYY HH:MI:SS';

col name heading "Database" format a10;
col df heading "Total|Datafiles|Backed Up" format 9999;
col al heading "Total|Archive logs|Backed Up" format 9999;
col othf heading "Total|Other files|Backed Up" format 9999;
col tag heading "Backup Mode" format a20;
col st heading "Start|Date/Time" format date;
col ct heading "Completion|Date/Time" format date;
col bt heading "Backup|Type" format a6;
col stat heading "Status" format a6;
col cfi heading "Ctrlfile|Included?" format a8;
col keep_until heading "Retention|Policy" format a20;
col stime noprint;

break on name

select name, decode(substr(p.tag,1,3),'TAG','ARCHIVE-LOG-BACKUP',p.tag) tag,
trunc(b.start_time) stime,
min(b.start_time) st, max(b.completion_time) ct,
sum(decode(p.BACKUP_TYPE, 'D', 1,0)) df,
sum(decode(p.BACKUP_TYPE, 'L', 1,0)) al,
sum(decode(p.BACKUP_TYPE, 'I', 1,0)) othf,
decode(p.BACKUP_TYPE, 'D', 'Full', 'Incr') bt,
DECODE(b.status,'A','Avail'
,'D','Deleted'
,'O','Unusable'
,b.status) stat,
keep_until
from rc_backup_set b, rc_database d, rc_backup_piece p
where b.db_key=d.db_key
and b.db_key=p.db_key
and b.bs_key=p.bs_key
group by name,p.tag,trunc(b.start_time),
p.backup_type,b.status,keep_until
order by min(b.start_time);

prompt;

clear columns;
clear breaks;
*EOF*
}

#---------------------------------------------------
# MAin
#---------------------------------------------------
if [ "$1" = "-h" ] ; then
   Usage
fi

ShowRman
