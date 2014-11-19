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
	
	model = createM3FromEclipseProject(proj);
	
	x = duplicatedPercentage(model,	24118);	
	println(x);
}

public real duplicatedPercentage(M3 model, int totalLines){
	
	//build up the set of all sequences and how many times they occur 
	map[str, id] empty = ();
	map[str, id] sequences = (empty | processFile(it, f, model) | f <- files(model) );
	
	int duplicatedLines =  (0 | it + sequences[e].cnt | e <- sequences); 
	assert duplicatedLines < totalLines : "duplicatedLines bigger than total lines of code";
	
	percentage = duplicatedLines / (totalLines * 1.0) * 100 ;
	assert percentage < 100 && percentage > 0 : "duplication not between 0% and 100%";
	return percentage;
}

//Scans a file for duplicated code.
private map[str, id] processFile(map[str, id] sequenceMap, loc file, M3 model)
{
	set[loc] docLoc = range(model@documentation);
	set[loc] docsInFile = {doc | doc <- docLoc, file.path == doc.path};	
	
	str cleanFileStr = filterDocInFile(model, file, docsInFile, true);
	
	assert size(cleanFileStr) <= size(readFile(file)) : "cleaned file is bigger than regular file";
	
	//split the file into lines
	list[str] lines = split("\r\n", cleanFileStr);

	if(size(lines) < seqLen) 
		return sequenceMap;
	
	for(i <- [0..size(lines) - seqLen]){
		int min = i;
		int max = min + seqLen;
		
		//build up the sequence string
		str sequence = ("" | it + lines[ii] | ii <- [min..max]);
			
		if(sequence in sequenceMap)
		{
			id x = sequenceMap[sequence];  
			if(x.cnt == 0)
				sequenceMap[sequence] = <x.file, x.begin, x.cnt + 2>;
			else
				sequenceMap[sequence] = <x.file, x.begin, x.cnt + 1>;
		}
		else
			sequenceMap[sequence] = <file, min, 0>;
	}
	return sequenceMap;	
}