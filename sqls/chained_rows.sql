User=$1
#Object=$2
sqlplus / <<*eof*
 
@$ORACLE_HOME/rdbms/admin/utlchain.sql
TRUNCATE TABLE CHAINED_ROWS;
analyze table $User list chained rows;
*eof*
 
