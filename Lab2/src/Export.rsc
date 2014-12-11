module Export

import Prelude;
import IO;
import lang::json::IO;

alias Sequence2 = [Statement];

public void exportToJsonFile(value x)
{
	iprintToFile(|project://Lab2/cloneClasses.js|,toJSON(x));
}

public void exportClonesToFile(map[Sequence2, [loc]] cloneClasses)
{
	loc cloneFile = (|project://Lab2/cloneClasses.txt|);
	
	writeFile(cloneFile, "");
	
	int i = 1;
	for(sequence <- cloneClasses, locs <- cloneClasses[sequence])
	{
		appendToFile("Clone class <i> }------------------------------------------------------------------------", x);
		example = readFile(locs[0]);
		appendToFile(cloneFile, example + "\r\n\r\n");	

		i += 1;
		for(location <- locs)
			appendToFile("<location>\r\n");
	}
	
	
		
}