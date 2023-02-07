REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM 
REM ------------------------------------------------------------------------
REM PURPOSE:
REM 
REM ------------------------------------------------------------------------

set linesize    96
set pages       100
set feedback    off
set verify 	off
set head 	off

col	product  for a30
col	version	 for a20
col	status	 for a26

SELECT * 
FROM product_component_version 
;

exit

