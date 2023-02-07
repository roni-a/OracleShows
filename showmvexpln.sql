
truncate table mv_capabilities_table;

EXEC dbms_mview.explain_mview('&1');

SELECT capability_name,
possible,
substr(msgtxt,1,80) AS msgtxt
FROM mv_capabilities_table
WHERE capability_name like '%FAST%'
/

exit
