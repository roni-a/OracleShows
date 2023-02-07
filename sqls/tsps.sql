REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on V$ tables
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Show tablespace status
REM ------------------------------------------------------------------------

set linesize    96
set pages       100
set verify 	off
set feedback    off

CREATE table dba_tsps_$$ as
       SELECT tablespace_name,sum(bytes)/1024/1024 MB,0 free,0 Largest,
              'ONL' stat,0 pct,'0' contents
       FROM dba_data_files f
       GROUP BY tablespace_name;
UPDATE dba_tsps_$$
       SET free=(SELECT sum(f.bytes)/1024/1024
                 FROM dba_free_space f
                 WHERE f.tablespace_name=dba_tsps_$$.tablespace_name);
UPDATE dba_tsps_$$
       SET largest=(SELECT max(f.bytes)/1024
                    FROM dba_free_space f
                    WHERE f.tablespace_name=dba_tsps_$$.tablespace_name);
UPDATE dba_tsps_$$
       SET stat=(SELECT decode(s.online$, 0, 'OFF', 1, 'ONL')
                FROM sys.ts$ s
                WHERE s.name=dba_tsps_$$.tablespace_name);
UPDATE dba_tsps_$$
       SET pct=(SELECT s.dflextpct
                FROM sys.ts$ s
                WHERE s.name=dba_tsps_$$.tablespace_name);
UPDATE dba_tsps_$$
       SET contents=(SELECT decode(s.contents$, 0, 'P', 1, 'T')
                FROM sys.ts$ s
                WHERE s.name=dba_tsps_$$.tablespace_name)
;
col MB                  for 999,999,999  head "Tot|(MB)"
col free                for 999,999,999      head "Free|(MB)"
col Largest             for 999,999,999 head "Largest   |Extent (K)"
col tablespace_name     for a30         head "Tablespace"
col percent             for a6          head "% Free"
col stat                for a4          head "Stat"
col pct                 for 99          head "Pct"
col contents            for a4          head "Type"
SELECT stat, contents, tablespace_name, MB, free, largest,
       '  '||round(free/MB*100,0)||'%' percent, pct
FROM dba_tsps_$$
;
set pages 0
prompt ---- ---- ------------------------------ ------------ ------------ ------------ ------

define Space1='Total                                   '
define Space2='              '
col sum(MB)		for 999,999,999
col sum(free)		for 999,999,999
select '&&Space1', sum(MB), sum(free), '&&Space2', round(sum(free)/sum(MB)*100,0)||'%' percent
FROM dba_tsps_$$
;

DROP table dba_tsps_$$
;
prompt

exit

