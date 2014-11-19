module SIGModelMetrics::Lib::CodeCleaning

import Prelude;
import String;
import IO;

//Parse Libraries
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

//Utility Libraries
import SIGModelMetrics::Lib::StringCleaning;

//filter documentation out of file
public str filterDocInFile(loc file, set[loc] commentsInFile, bool filterTabs)
{
	fileStr = readFile(file);
	backup = fileStr;
	
	//loop through documentation elements, convert to spaces
	for(docloc <- commentsInFile)
	{	  
	  //<pre comment string> + <space> + <post comment string>
	  fileStr = replSubStr(fileStr, 
	  						docloc.offset, 
	  						docloc.offset + size(readFile(docloc)), 
	  						" ");
	}
	assert size(fileStr) == size(backup) : "filterDocInFile size(fileStr) != size(backup)";
	
  	if(filterTabs)
 		return filterExcessWhiteSpace(fileStr);
  	else 
  		return filterEmptyLines(fileStr);
}

public str filterDocInMethod(loc method, set[loc] commentsInFile, bool filterTabs)
{
  str methodStr = readFile(method);

  for(comment <- commentsInFile)
  {  
    //if comment is within method body
    if(   comment.offset >= method.offset 
       && comment.offset <= method.offset + size(methodStr))
     {      	
     	comStart = comment.offset - method.offset;
     	comEnd = comStart + size(readFile(comment));
     	
     	methodStr = replSubStr(methodStr, comStart, comEnd, " ");	
     }
  }	
  if(filterTabs)
 	return filterExcessWhiteSpace(methodStr);
  else 
  	return filterEmptyLines(methodStr);
}