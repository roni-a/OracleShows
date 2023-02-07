create or replace procedure accusleep ( seconds_in number )
is
   v_chunk_size constant integer := 100;
   v_compensation constant number := 0.976;
   v_chunks integer;
   v_remainder integer;
   v_seconds integer;
begin
   v_seconds := seconds_in * v_compensation;
   v_chunks := trunc(v_seconds/v_chunk_size);
   v_remainder := mod(v_seconds, v_chunk_size);

   for i in 1..v_chunks
   loop
      dbms_lock.sleep(v_chunk_size);
   end loop;
   dbms_lock.sleep(v_remainder);

   --dbms_output.put_line(v_chunks);
   --dbms_output.put_line(v_remainder);

end;
/

sho err

exit;
