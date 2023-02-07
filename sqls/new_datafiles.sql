set feedback off
set head off
set linesize 200
set verify off

select 'alter tablespace ' || t.TABLESPACE_NAME || chr(10) ||':'|| ' add datafile ' || '''' || d.FILE_NAME || '''' || ' size ' || (d.BYTES)/1024/1024 || 'M ' || '; ' || chr(10) || ':' || chr(10) || ':' from dba_tablespaces t, dba_data_files d where t.TABLESPACE_NAME=d.TABLESPACE_NAME and t.TABLESPACE_NAME='&1'  and d.FILE_NAME not in (select min(FILE_NAME) from dba_data_files where TABLESPACE_NAME='&1')
;

exit;

