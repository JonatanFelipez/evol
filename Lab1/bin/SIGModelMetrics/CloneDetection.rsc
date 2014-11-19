module SIGModelMetrics::CloneDetection

import IO;
import prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import SIGModelMetrics::Lib::CodeCleaning;


//The length of the sequence to check on
int seqLen = 6;
//To identify a sequence uniquely, define it by:
alias id = tuple[
	loc file, 	  // The file it is in
	int	begin, 	  // The index of the first line of the sequence
	int cnt];	  // The amount of times it is duplicated

public real duplicatedPercentage(M3 model, int totalLines){
	
	//start with zero, save the transformed text 
	//map[str, id] lines = ();
	
	// Iterate through all files
	//for(file <- files(model))
	//	hash = scanFile(hash, f);
	
	//build up the set of all sequences and how many times they occur 
	map[str, id] sequences = (() | scanFile(hash, e, model) | f <- files );
	int duplicatedLines =  (0 | it + allSeqs[e].cnt | e <- allSeqs ); 
	
	return duplicatedLines / (totalLines * 1.0);
}

//Scans a file for duplicated code.
private map[str, id] scanFile(map[str, id] sequences, loc file, M3 model)
{
	// public str filterDocInFile(M3 model, loc file, set[loc] commentsInFile, bool filterTabs)
	
	
	//TODO: filter comments, tabs, excess whitespace, empty lines
	cleanFileStr = readFile(file);
	
	//split the file into lines
	lines = split("\r\n", cleanFileStr);
	
	for(i <- [0..size(lines) - seqLen]){
		min = i;
		max = min + seqLen;
		
		//build up the sequence string
		str sequence = ("" | it + lines[ii] | ii <- [min..max]);
			
		if(sequence in sequences)
			sequences[sequence].cnt += 1; // hash[seqCode].count + 1;
		else
			sequences[sequence] = <file, <min,max>, file, 0>;
	}	
	return hash;	
}


