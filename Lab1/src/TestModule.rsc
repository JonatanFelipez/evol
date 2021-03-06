module TestModule

import Prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

import IO;
import String;

//project location
loc project = |project://smallsql|;
loc testfile = |project://Lab1/src/Testcase.java|;

public void main2() 
{
	//m3 model
	model = createM3FromEclipseProject(project);	
	
	//lines of code
	classloc = classes(model);
	println(
		sum([ countLinesOfClass(i) | i <- classloc ]) 
		);
			
	docSections = model@documentation;
	
} 

public M3 makeModel()
{
	return createM3FromEclipseProject(project);
}

// What does commentsInMethod look like, what do the coordinates relate to (offset in file/method?)
public int countLOCofMethod(M3 model, loc method, 
		     rel[loc ,loc] commentsInMethod)
{
	//convert method to text
	str methodText = readFile(method);
	
	int begin = method.offset;
	
	//loop through documentation elements, convert to spaces
	for(docloc <- range(model@documentation))
	{
	  //convert file location into string
	  docstring = readFile(docloc);
      
      //build up space string that is as long as the comment 
	  space = ("" | it + " " | int e <- [1..docloc.length + 1]);
	  
	  //<pre comment string> + <space> + <post comment string>
	  filetext = substring(filetext, begin, docloc.offset ) +
	  			 space +
	   			 substring(filetext, docloc.offset + size(docstring), size(filetext));			   			  
	}
	
	return filterWhitespace(filetext);
}

public int countLOCofFile(M3 model, loc file, set[loc] commentsInFile)
{
	//convert file to text
	str filetext = readFile(file);
	
	//loop through documentation elements, convert to spaces
	for(docloc <- commentsInFile)
	{
	  //convert documentation location into string
	  docstring = readFile(docloc);
      
      //build up space string that is as long as the comment 
	  space = ("" | it + " " | int e <- [1..docloc.length + 1]);
	  
	  //<pre comment string> + <space> + <post comment string>
	  filetext = substring(filetext, 0, docloc.offset ) +
	  			 space +
	   			 substring(filetext, docloc.offset + size(docstring), size(filetext));	   				   			  
	}
	
	return filterWhitespace(filetext);
}

public int filterWhitespace(str text)
{
	//split on windows newline
	list[str] lines = split("\r\n",text);
	
	//filter on whitespace lines
	edited = [line | line <- lines, !(/^\s*$/ := line)];
	
	//Debug: show result of edited text, with newlines intercalated
	println("=========== 
			 Debug: result without whitespace and comments 
			 ===========\r\n 
			 <intercalate("\r\n",edited)>"
		    );
	
	//return the number of lines
	return size(edited);
}

public void volume(M3 model, set[Declaration] ast) 
{}

public void unitSize(M3 model)
{}

public void unitComplexity(M3 model)
{}

public void duplication(M3 model)
{}