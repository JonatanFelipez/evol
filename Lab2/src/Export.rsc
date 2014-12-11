module Export

import lang::json::IO;

import Prelude;
import Map;
import String;

//Java Parsing libraries
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;

alias Sequence2 = list[Statement];

public void exportToJsonFile(map[Sequence2, list[int]] cloneClasses)
{	
	loc cloneFile = (|project://Lab2/cloneClasses.js|);
	map[int , list[int]] values = ();
	int i = 1;
	writeFile(cloneFile, "var cloneClasses = [");
	for(sequence <- cloneClasses)
	{
		if(i < size(cloneClasses))
			appendToFile(cloneFile, "{<i> : [<cloneClasses[sequence][0]>,<cloneClasses[sequence][1]>]},");
		else
			appendToFile(cloneFile, "{<i> : [<cloneClasses[sequence][0]>,<cloneClasses[sequence][1]>]}");
		
		i += 1;
	}
	appendToFile(cloneFile, "];");
}

public void exportClonesToFile(map[Sequence2, list[loc]] cloneClasses)
{
	loc cloneFile = (|project://Lab2/cloneClasses.txt|);
	
	writeFile(cloneFile, "");
	
	int i = 1;
	
	for(sequence <- cloneClasses)
	{
		locs = cloneClasses[sequence];
		appendToFile(cloneFile, "Clone class <i> }------------------------------------------------------------------------ \r\n");
		example = readFile(locs[0]);
		appendToFile(cloneFile, example + "\r\n\r\n");	

		i += 1;
		for(location <- locs)
			appendToFile(cloneFile,"<location>\r\n");
			
		appendToFile(cloneFile, "\r\n");
	}
}
