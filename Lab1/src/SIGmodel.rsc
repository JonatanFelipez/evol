module SIGmodel
import Prelude;
import String;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import IO;
import String;


public void main()
{
	project = |project://smallsq|;
	model = createM3FromEclipseProject(project);	
	println(sigLinesOfCode(model));	
}

public void volume(M3 model)
{
	println(sigLinesOfCode(model));		
}

public int unitSize(M3 model)
{
	docloc = range(model@documentation); //location of all documentation in the project	
	
	filelocs = files(model);

	
	{N | N <- model@declarations, N[0].scheme == "java+method"};
	
	
}

public int sigLinesOfCode(M3 model)
{
	fileloc = files(model); 			 //location of all the files in the project
	docloc = range(model@documentation); //location of all the documentation in the project
    
    int totalLines = 0; 
    
    //calculate the lines of code for each file  
    for(file <- fileloc)
    {
    	docsInFile = {n | loc n <- docloc, file.file == n.file};
    	totalLines = totalLines + countLOCofFile(model, file, docsInFile); 	
    }
    return totalLines;
}

//count the lines of code in a file
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

//filter excess lines out of text and count the lines
public int filterWhitespace(str text)
{
	//split on windows newline
	list[str] lines = split("\r\n",text);
	
	//filter on whitespace lines
	edited = [line | line <- lines, !(/^\s*$/ := line)];
	
	//Debug: show result of edited text, with newlines intercalated
	/*
	println("=========== 
			 Debug: result without whitespace and comments 
			 ===========\r\n 
			 <intercalate("\r\n",edited)>"
		    );*/
	
	//return the number of lines
	return size(edited);
}


