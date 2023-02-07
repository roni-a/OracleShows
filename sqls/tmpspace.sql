set feedback off
set head off
set linesize 200

select 'create tablespace '||t.TABLESPACE_NAME||chr(10)||':'||' datafile '||chr(10)||':'||' '''||d.FILE_NAME ||''''||' size '||(d.BYTES)/1024/1024||'M'||chr(10)||':'||' default storage ('||chr(10)||':'||' initial '||(t.INITIAL_EXTENT)/1024||'K'||chr(10)||':'||' next '||(t.NEXT_EXTENT)/1024||'K'||chr(10)||':'||' pctincrease '||t.PCT_INCREASE||chr(10)||':'||' maxextents '||MAX_EXTENTS||chr(10)||':'||') '||CONTENTS||chr(10)||':'||';'||chr(10)||':'||chr(10)||':'from dba_tablespaces t, dba_data_files d where t.TABLESPACE_NAME=d.TABLESPACE_NAME and t.TABLESPACE_NAME='TEMP' and (d.FILE_NAME like '%\_1.dbf%' ESCAPE '\' or d.FILE_NAME like '%\_01.dbf%' ESCAPE '\') 
;

exit;

