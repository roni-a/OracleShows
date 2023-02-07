set feedback off
set head off
set linesize 200

select 'create tablespace '||t.TABLESPACE_NAME||chr(10)||':'||' datafile '||chr(10)||':'||' '''||d.FILE_NAME ||''''||' size '||(d.BYTES)/1024/1024||'M'||chr(10)||':'||' extent management local autoallocate;' from dba_tablespaces t, dba_data_files d where t.TABLESPACE_NAME=d.TABLESPACE_NAME and t.TABLESPACE_NAME='RBS' and (d.FILE_NAME like '%\_1.dbf%' ESCAPE '\' or d.FILE_NAME like '%\_01.dbf%' ESCAPE '\') 
;

exit;

