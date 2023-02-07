set head off
select FILE_NAME from dba_data_files where TABLESPACE_NAME='SYSTEM' and (FILE_NAME like '%\_1.dbf%' ESCAPE '\' or FILE_NAME like '%\_01.dbf%' ESCAPE '\') 
/
exit;

