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

SELECT REPLACE(version ,'.','')
FROM product_component_version 
WHERE product like '%Enterprise Edition%' 
   OR product like '%Server%' 
/

exit
/
