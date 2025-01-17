set pig.enable.plan.serialization false;
--flatten.pig
player = load '/user/root/data/baseball.txt' 
	  as (name:chararray, team:chararray,
		pos:bag{t:(p:chararray)},bat:map[]);  
		
noempty = foreach player generate name,
            ((pos is null or IsEmpty(pos)) ? {('unknown')} : pos)
            as position;

player1 = LIMIT noempty 20;
dump player1;

pos     = foreach player generate name, flatten(pos) as position;
bypos   = group pos by position;
bypos1 = LIMIT bypos 1;
dump bypos;
