-- ===================================================
-- Show the object according to FILE# and BLOCK#
-- ===================================================
col segment for a35
col PARTITION_NAME for a25
col tablespace for a25

SELECT  owner||'.'||segment_name as segment,
        partition_name,
        segment_type,
        tablespace_name as tablespace,
        file_id,
        block_id,
        blocks
FROM    dba_extents
WHERE   file_id = &&1
AND     block_id           <= &&2
AND    (block_id + blocks) >= &&2;

prompt
exit;

