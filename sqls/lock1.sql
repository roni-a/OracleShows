SELECT SID,
			 USERNAME,
			 TERMINAL,
			 PROGRAM 
FROM   GV$SESSION
WHERE  SADDR IN (SELECT KGLLKSES 
		             FROM   X$KGLLK LOCK_A
	               WHERE  KGLLKREQ = 0
	               AND    EXISTS (SELECT LOCK_B.KGLLKHDL i
								 	              FROM   X$KGLLK LOCK_B
		                            WHERE  KGLLKSES = 'saddr_from_v$session' /* BLOCKED SESSION */
		                            AND    LOCK_A.KGLLKHDL = LOCK_B.KGLLKHDL
		                            AND    KGLLKREQ > 0)
                );
