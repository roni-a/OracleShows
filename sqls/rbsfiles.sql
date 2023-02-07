set feedback off
set head off
set linesize 200

select 'alter tablespace ' || t.TABLESPACE_NAME || chr(10) ||':'|| ' add datafile ' || '''' || d.FILE_NAME || '''' || ' size ' || (d.BYTES)/1024/1024 || 'M ' || '; ' || chr(10) || ':' || chr(10) || ':' from dba_tablespaces t, dba_data_files d where t.TABLESPACE_NAME=d.TABLESPACE_NAME and t.TABLESPACE_NAME in ('RBS','TEMP') and (d.FILE_NAME not like '%\_1.dbf%' ESCAPE '\' and d.FILE_NAME not like '%\_01.dbf%' ESCAPE '\') 
;

exit;

