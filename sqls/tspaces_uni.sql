set feedback off
set head off
set linesize 200
set verify off

select 'create tablespace '||t.TABLESPACE_NAME||chr(10)||':'||' datafile '||chr(10)||':'||' '''||d.FILE_NAME ||''''||' size '||(d.BYTES)/1024/1024||'M'||chr(10)||':'||' extent management local uniform size '||(t.INITIAL_EXTENT)/1024||'K;'||chr(10)||':'||chr(10)||':' from dba_tablespaces t, dba_data_files d where t.TABLESPACE_NAME=d.TABLESPACE_NAME and t.TABLESPACE_NAME='&1' and (d.FILE_NAME like '%\_1.dbf%' ESCAPE '\' or d.FILE_NAME like '%\_01.dbf%' ESCAPE '\')
;

exit;

