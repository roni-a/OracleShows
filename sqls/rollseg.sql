set feedback off
set head off
set linesize 200


select chr(10)||':'||'create rollback segment '||d.SEGMENT_NAME||' tablespace '||d.TABLESPACE_NAME||chr(10)||':'||'storage ('||chr(10)||':'||'initial '||(d.INITIAL_EXTENT)/1024||'K'||chr(10)||':'||'next '||(d.NEXT_EXTENT)/1024||'K'||chr(10)||':'||'minextents '||d.MIN_EXTENTS||chr(10)||':'||'maxextents '||d.MAX_EXTENTS||chr(10)||':'||'optimal '||(s.OPTSIZE)/1024/1024||'M'||chr(10)||':'||');' from  dba_rollback_segs d, v$rollname n, v$rollstat s where s.USN=n.USN and n.NAME=d.SEGMENT_NAME and d.SEGMENT_NAME not like 'SYSTEM'
;

exit;

