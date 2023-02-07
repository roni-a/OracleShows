create or replace procedure dump_table_to_csv( p_tname     in varchar2,
                                               p_dir       in varchar2,
                                               p_filename  in varchar2,
																						   p_condition in varchar2)
is
      l_output        utl_file.file_type;
      l_theCursor     integer        default dbms_sql.open_cursor;
      l_columnValue   varchar2(4000);
      l_status        integer;
      l_query         varchar2(1000) default 'select * from ' || p_tname ||' ';
      l_colCnt        number := 0;
      l_separator     varchar2(1);
      l_descTbl       dbms_sql.desc_tab;
begin
      l_output := utl_file.fopen( 'TEMP_DIR', p_filename, 'w' );
      execute immediate 'alter session set nls_date_format=''dd-mon-yyyy hh24:mi:ss''';

			if p_condition is not null
			then
				 l_query := l_query || p_condition;
		  end if;

			dbms_output.put_line(l_query);
  
      utl_file.fclose( l_output );
  
      dbms_sql.parse(  l_theCursor,  l_query, dbms_sql.native );

      execute immediate 'alter session set nls_date_format=''dd-MON-yy'' ';
exception
      when others then
          execute immediate 'alter session set nls_date_format=''dd-MON-yy'' ';
          raise;
end;
/

show err

prompt set serverout on
prompt exec dump_table_to_csv( 'OOVOO_ODS.DOWNLOAD_CHANNEL_ITEMS','/tmp','OOVOO_ODS.DOWNLOAD_CHANNEL_ITEMS','WHERE DATECREATED >= ''01-jan-2012''');
exit

--      dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl );
create or replace procedure dump_table_to_csv( p_tname     in varchar2,
                                               p_dir       in varchar2,
                                               p_filename  in varchar2,
																						   p_condition in varchar2)
is
      l_output        utl_file.file_type;
      l_theCursor     integer        default dbms_sql.open_cursor;
      l_columnValue   varchar2(4000);
      l_status        integer;
      l_query         varchar2(1000) default 'select * from ' || p_tname ||' ';
      l_colCnt        number := 0;
      l_separator     varchar2(1);
      l_descTbl       dbms_sql.desc_tab;
begin
      l_output := utl_file.fopen( 'TEMP_DIR', p_filename, 'w' );
      execute immediate 'alter session set nls_date_format=''dd-mon-yyyy hh24:mi:ss''';

			if p_condition is not null
			then
				 l_query := l_query || p_condition;
		  end if;

			dbms_output.put_line(l_query);
  
  
      for i in 1 .. l_colCnt loop
          utl_file.put( l_output, l_separator || '"' || l_descTbl(i).col_name || '"');
          dbms_sql.define_column( l_theCursor, i, l_columnValue, 4000 );
          l_separator := ',';
      end loop;
      utl_file.new_line( l_output );
  
      l_status := dbms_sql.execute(l_theCursor);
  
--      while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
--          l_separator := '';
--          for i in 1 .. l_colCnt loop
--              dbms_sql.column_value( l_theCursor, i, l_columnValue );
--              utl_file.put( l_output, l_separator || l_columnValue );
--              l_separator := ',';
--          end loop;
--          utl_file.new_line( l_output );
--      end loop;

    while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
        l_separator := '';
        for i in 1 .. l_colCnt loop
            dbms_sql.column_value( l_theCursor, i, l_columnValue );
            -- if the separator or quote is embedded in the value then enclose in double-quotes
            if instr(l_columnValue, ',') != 0 or instr(l_columnValue, '"') then
                l_quote := '"';
                -- double any/all embedded quotes
                l_columnValue := replace(l_columnValue,'"','""');
            else
                l_quote := '';
            end if;
            utl_file.put( l_output, l_separator || l_quote || l_columnValue || l_quote);
            l_separator := ',';
        end loop;
        utl_file.new_line( l_output );
    end loop;


      dbms_sql.close_cursor(l_theCursor);
      utl_file.fclose( l_output );
  
      execute immediate 'alter session set nls_date_format=''dd-MON-yy'' ';
exception
      when others then
          execute immediate 'alter session set nls_date_format=''dd-MON-yy'' ';
          raise;
end;
/

show err

set serverout on
prompt exec dump_table_to_csv( 'OOVOO_ODS.DOWNLOAD_CHANNEL_ITEMS','/tmp','OOVOO_ODS.DOWNLOAD_CHANNEL_ITEMS','WHERE DATECREATED >= ''01-jan-2012''');
