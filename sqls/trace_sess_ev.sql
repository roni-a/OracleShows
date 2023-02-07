Level=$3
 if [ "X$Level" = "X" ]
  then Level=8 
   else if  [ "$Level" != "12" -a "$Level" != "8" ] 
   then echo "Wrong level, only [8|12]"  
 fi
        fi
sqlplus system <<*EOF*
alter system set timed_statistics=true;
exec sys.dbms_system.set_ev('$1','$2',10046,'$Level','');
*EOF*


