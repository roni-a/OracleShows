REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on dba_data_files, dba_extents v$parameter 
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show datafile High Water Mark 
REM ------------------------------------------------------------------------

set linesize    96
set pages       100
set feedback    off

col file_name    for a50
col current_size for 9,999
col highwater    for 9,999
col saving       for 9,999

select a.file_name, a.BYTES/1024/1024 current_size,
       ((b.maximum+c.blocks-1)*d.db_block_size)/1024/1024 highwater,
       a.BYTES/1024/1024 - ((b.maximum+c.blocks-1)*d.db_block_size)/1024/1024 saving
from   dba_data_files a,
       (select file_id,max(block_id) maximum
               from dba_extents
               group by file_id) b,
       dba_extents c,
       (select value db_block_size
               from v$parameter
               where name='db_block_size') d
where a.file_id  = b.file_id
and   c.file_id  = b.file_id
and   c.block_id = b.maximum
and   (a.BYTES/1024/1024 - ((b.maximum+c.blocks-1)*d.db_block_size)/1024/1024) > 50
order by a.file_name
;
prompt

--exit

