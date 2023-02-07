REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on dba_data_files, dba_extents v$parameter 
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show datafile High Water Mark 
REM ------------------------------------------------------------------------

set pages       100
set echo off verify off feedback off linesize 220

col file_name    for a50
col current_size for 9,999
col highwater    for 9,999
col saving       for 9,999

col blocksize 	 new_value xblocksize 	noprint
select to_number(value) blocksize from v$parameter where name='db_block_size';

select a.file_name, 
	a.BYTES/1024/1024 current_size,
       ((b.maximum+c.blocks-1) * &xblocksize)/1024/1024 highwater,
       a.BYTES/1024/1024 - ((b.maximum+c.blocks-1) * (&xblocksize))/1024/1024 saving
from   dba_data_files a,
       (select file_id,max(block_id) maximum
               from dba_extents
               group by file_id) b,
       dba_extents c
where a.file_id  = b.file_id
and   c.file_id  = b.file_id
and   c.block_id = b.maximum
and   (a.BYTES/1024/1024 - ((b.maximum+c.blocks-1) * (&xblocksize))/1024/1024) > 50
order by a.file_name
;
prompt

exit

