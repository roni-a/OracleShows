set echo off veri off feed off lines 180 pages 600 timin on
col failover_type   head "FailOver|Type"
col failover_method head "FailOver|Method"

select /*+ first_lines */
       username, sid, serial#,process,failover_type,failover_method
FROM gv$session
where upper(failover_method) != 'BASIC'
and upper(failover_type) !='SELECT'
and upper(username) not in ('SYS','SYSTEM','SYSMAN','DBSNMP','MORE','ZABBIX','OPS$ORACLE')
order by 1, 2
/
prompt

exit
