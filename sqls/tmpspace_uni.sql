set feedback off
set head off
set linesize 200

select 'create temporary tablespace TEMP'||chr(10)||':'||'tempfile '||chr(10)||':'||' '''||d.FILE_NAME ||''''||' size '||(d.BYTES)/1024/1024||'M'||chr(10)||':'||'extent management local uniform '||(t.INITIAL_EXTENT)/1024||'K;' from dba_tablespaces t, dba_temp_files d where t.TABLESPACE_NAME=d.TABLESPACE_NAME and t.TABLESPACE_NAME='TEMP' and (d.FILE_NAME like '%\_1.dbf%' ESCAPE '\' or d.FILE_NAME like '%\_01.dbf%' ESCAPE '\') 
;

exit;

