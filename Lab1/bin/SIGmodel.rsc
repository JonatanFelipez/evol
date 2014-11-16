module SIGmodel
import Prelude;
import String;

//Java Parsing libraries
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

//Utility Libraries
import SIGModelMetrics::Lib::StringCleaning;
import SIGModelMetrics::Lib::CodeCleaning;

//Metric Libraries


public void main2()
{
	project 	= |project://smallsql|;
	testProject = |project://Lab1/src/Testcase.java|;
	model 		=  createM3FromEclipseProject(project);	
	println(projectLinesOfCode(model));	
}

public map[str,int] unitSize(M3 model)
{
	//location of all documentation and files in the project	
	docLoc = range(model@documentation); 
	fileLocs = files(model);

	//get all method declarations in the project
	methLocs = { dec | dec <- model@declarations, dec[0].scheme == "java+method"};
	
	//map a method filepath to the line 
	map[str, int] method2LoC = ();
	
	for(method <- methLocs)
	{
	  //get all documentation in the file that contains the method 
	  docsInFile = {doc | doc <- docloc, doc.path == method[1].path};
	  
	  method2LoC = method2LoC + 
	  	(method[0].path : methodSize(model, method[1], docsInFile));
	}	
	return method2LoC;
	
}
//calculate the LoC of a method without counting the documentation
public int methodSize(M3 model, loc method, set[loc] docsInFile)
{
  str methodStr = readFile(method);
  str backupStr = methodStr;

  for(doc <- docsInFile)
  {  
    //if comment is within method body
    if(   doc.offset > method.offset 
       && doc.offset < method.offset + size(methodStr))
     {  
     	//calculate boundaries of documentary in method    	
     	docStart = doc.offset - method.offset;
     	docEnd = docStart + size (readFile(doc));
     	
     	methodStr = replSubStr(methodStr, docStart, docEnd, " ");	
     }
  }	
  return filterEmptyLines(methodStr);
}

public int projectLinesOfCode(M3 model)
{
	files  = files(model); 			     //location of all the files in the project
	docLoc = range(model@documentation); //location of all the documentation in the project
    
    int totalLines = 0; 
    
    //calculate the lines of code for each file  
    for(file <- files)
    {	    
    	docsInFile = {doc | doc <- docLoc, file.path == doc.path};
    	cleanFile = filterDocInFile(model, file, docsInFile);
    	totalLines = totalLines + size(split("\r\n", cleanFile));	
    }
    return totalLines;
}

