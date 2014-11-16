module SIGModelMetrics::CloneDetection

import IO;
import prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import util::Math;

/*
	tuple[where to find sequence, 
	      min and max line numbers, 
	      amount of times found duplicated
	     ]
*/
alias seqRepres = tuple[loc file, tuple[int,int] minMax, int count];

public str runCloneDetection(M3 model){
	
	//init hashset
	map[str, seqRepres] hash = ();
	
	//
	for(file <- files(model)){
		hash = scanFile(hash, f);
	}
	return calculateRank(uniqueLines(getDuplicatedSequences(hash)), 100);
}

//scans a file for duplicated code.
private map[str, seqRepres] scanFile(map[str, seqRepres] hash, loc file)
{
	//TODO: filter comments, tabs, excess whitespace, empty lines
	cleanFileStr = readFile(file);
	
	lines = split("\r\n", cleanFileStr);
	
	for(i <- [0..size(source) - 6]){
		min = i;
		max = i+6;
		
		str seqCode = "";
		
		for(j <- [min..max])
			seqCode += source[j] + "\r\n";
		
		if(seqCode in hash)
			hash[seqCode].count = hash[seqCode].count + 1;
		else
			hash[seqCode] = <file, <min,max>, file, 0>;
	}	
	return hash;	
}