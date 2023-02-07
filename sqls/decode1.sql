@compute
set echo off
set  term on
set pages 1000
select
sum(decode(ts.name,'DRSYS', seg.blocks*ts.blocksize/1024/1024,0)) DRSYS,                                                                                                                                                                                                                                                                                                                                        
sum(decode(ts.name,'POOL_DATA', seg.blocks*ts.blocksize/1024/1024,0)) POOL_DATA,                                                                                                                                                                                                                                                                                                                                
sum(decode(ts.name,'PRECISE', seg.blocks*ts.blocksize/1024/1024,0)) PRECISE,                                                                                                                                                                                                                                                                                                                                    
sum(decode(ts.name,'USER_DATA', seg.blocks*ts.blocksize/1024/1024,0)) USER_DATA,                                                                                                                                                                                                                                                                                                                                
sum(decode(ts.name,'USER_INDEXES', seg.blocks*ts.blocksize/1024/1024,0)) USER_INDEXES,                                                                                                                                                                                                                                                                                                                          
sum(decode(ts.name,'VOLTEST_DATA', seg.blocks*ts.blocksize/1024/1024,0)) VOLTEST_DATA,                                                                                                                                                                                                                                                                                                                          
sum(decode(ts.name,'VOLTEST_IX', seg.blocks*ts.blocksize/1024/1024,0)) VOLTEST_IX,                                                                                                                                                                                                                                                                                                                              
us.name Username
FROM sys.ts$ ts,
sys.user$ us,
sys.seg$ seg
WHERE seg.user# = us.user#
AND ts.ts# = seg.ts#
GROUP BY us.name
/
exit
