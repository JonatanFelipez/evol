module SIGModelMetrics::Lib::StringCleaning

import Prelude;
import String;
import IO;

//remove all excess whitespace from a string
public str filterExcessWhiteSpace(str source)
{	
	allLines = split("\r\n", source);
	
	//filter whitespace lines
	lines = [line | line <- allLines, !(/^\s*$/ := line)];
	
	cleanSource = "";	
	for(line <- lines)
	{
	 	//remove tabs and excess whitespace
	 	spaceline = split(" ", trim(replaceAll(line, "\t", "")));
	 	
	 	//rebuild source without all excess whitespace
	    cleanSource = cleanSource + "\r\n" +
	    	intercalate(" ", [x | x <- spaceline, x != ""]);
	} 
	
	assert size(cleanSource) <= size(source) : "filterExcessWhiteSpace() returns bigger result.";
	
	return cleanSource;
}

//remove all whitespace lines from a string
public str filterEmptyLines(str source)
{
	//split on windows newline
	lines = split("\r\n", source);
	
	//filter out lines that are empty
	res = intercalate("\r\n", [line | line <- lines, !(/^\s*$/ := line)]);
	
	assert size(res) <= size(source) : "filterEmptyLines() returns bigger result.";
	return res;
}

//replace each character of substring with replacement string
public str replSubStr(str source, int iStart, int iEnd, str replacement)
{
    //<pre comment string> + <space> + <post comment string>	
    res = substring(source, 0, iStart) +
	  	   ("" | it + replacement | e <- [0..(iEnd - iStart)]) +
	   	   substring(source, iEnd, size(source));	  
	
	assert size(source) == size(res) : "replSubStr size(source) != size(res)";
	return res;
}

