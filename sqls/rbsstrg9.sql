clear buffer

set feed off
set verify off
set linesize 90
set pagesize 90

column bytes 		for 999,999,999
column segment_name 	for a11 		head "Segment"
col tablespace_name	for a8          	head TS
column extents 		for 999 truncate 	head "Ext"
column initial_extent 	for 99,999,999 		head "Initial"
column next_extent 	for 99,999,999 		head "Next"
column min_extents   	for 999 		head "Min"
column max_extents   	for 99,999 		head "Max"
column segment_type 	for a8

SELECT  segment_name, tablespace_name, min_extents, max_extents, extents, 
        bytes, initial_extent, next_extent 
FROM dba_segments 
WHERE segment_type in ('ROLLBACK','TYPE2 UNDO'); 

exit
/
