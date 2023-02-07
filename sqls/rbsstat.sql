REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ and dba_* tables
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show rollback segments status and statistics
REM ------------------------------------------------------------------------

set linesize    96
set pages       100
set feedback    off

col segment_name	for a6 		head Name
col rss			for 999999	head "Rssize|(KB)"
col opt			for 999999	head "Optsize|(KB)"
col usn 		for 99 		head Id
col extents 		for 999 	head Ext 
col writes 		for 9,999,999,999	head Writes
col xacts		for 99 		head "Act|Trx"
col status		for a3 truncate head Stat
col wraps 		for 9999	head Wrap
col waits		for 999		head Wait
col gets 		for 999,999,999	head Gets
col shrinks 		for 999		head Shrink

SELECT d.segment_name, rssize/1024 rss, optsize/1024 opt, usn, extents, writes, 
       xacts, d.status, wraps, waits, gets, shrinks
FROM v$rollstat s, dba_rollback_segs d
WHERE s.usn = d.segment_id
;

prompt

exit

