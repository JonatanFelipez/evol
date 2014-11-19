module SIGModelMetrics::Duplication

import IO;
import Prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import SIGModelMetrics::Lib::CodeCleaning;


//The length of the sequence to check on
int seqLen = 6;
//To identify a sequence uniquely, define it by:
alias id = tuple[
	loc file, 	  // The file it is in
	int	begin, 	  // The index of the first line of the sequence
	int cnt ];	  // The amount of times it is duplicated

public void testDup(loc proj){
	x = duplicatedPercentage(
		 	createM3FromEclipseProject(proj),
			24300);
	
	println(x);
}

public real duplicatedPercentage(M3 model, int totalLines){
	
	//build up the set of all sequences and how many times they occur 
	map[str, id] empty = ();
	map[str, id] sequences = (empty | scanFile(it, f, model) | f <- files(model) );
	int duplicatedLines =  (0 | it + sequences[e].cnt | e <- sequences); 
	
	return duplicatedLines / (totalLines * 1.0) * 100 ;
}

//Scans a file for duplicated code.
private map[str, id] scanFile(map[str, id] sequenceMap, loc file, M3 model)
{
	// public str filterDocInFile(M3 model, loc file, set[loc] commentsInFile, bool filterTabs)
	docsInFile = d
	
	//TODO: filter comments, tabs, excess whitespace, empty lines
	str cleanFileStr = readFile(file);
	
	//split the file into lines
	list[str] lines = split("\r\n", cleanFileStr);
	
	for(i <- [0..size(lines) - seqLen]){
		int min = i;
		int max = min + seqLen;
		
		//build up the sequence string
		str sequence = ("" | it + lines[ii] | ii <- [min..max]);
			
		if(sequence in sequenceMap)
		{
			id x = sequenceMap[sequence];  
			sequenceMap[sequence] = <x.file, x.begin, x.cnt + 1>;
		}
		else
			sequenceMap[sequence] = <file, min, 0>;
	}
	return sequenceMap;	
}