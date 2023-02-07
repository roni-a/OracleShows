set echo off feed off ver off lines 120 pages 600

SELECT          /*+ ORDERED */
       DISTINCT RAWTOHEX (s.address) address, s.sql_text, s.hash_value,
                0 piece
           FROM v$open_cursor c, v$sql s
          WHERE SID = &1
            AND c.hash_value = s.hash_value
            AND c.address = s.address
       ORDER BY address, piece
/

exit
