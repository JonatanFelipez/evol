module JeffTestModule

import Prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

import IO;
import String;

//project location
//project = |project://Lab1/Testcase.java|;
//createM3FromEclipseProject(project);
public void sigLinesOfCode(M3 model) 
{
	//lines of code
	fileloc = files(model); //location of all the files in project set[loc]
	docloc = range(model@documentation); //location of all documentation in project set[loc]
			
	for(X <- docloc)
	{		
		filelocation = {N| loc N <- fileloc, N.file == X.file}; //Get the file location from set of files
		if(!isEmpty(filelocation))
		{		
			//remove comments
			file = readFile(getOneFrom(filelocation));
			doc = readFile(X);
			
			str space = "";
			
			for(i<- [0..size(doc)])
				space = space + " ";
				
			str p1 = substring(file, 0, X.offset);
			str p2 = substring(file, X.offset + size(doc), size(file));
			filetext = p1 + space + p2;
			print(filetext);
		}		
	}
	/*
	println(
		sum([ countLinesOfClass(i) | i <- fileloc ]) 
		);
			
	docSections = model@documentation;
	*/	
} 

public int countLinesOfClass(loc classLoc)
{
	classStr = readFile(classLoc);
	
	filterComments(classStr);
	
	return size(filterComments(classStr));
}

public void test1()
{
	classText = readFile(|project://Lab1/src/Testcase.java|);
	//println(classText);
	//println(filterComments(classText));
	filterComments(classText);
}

public str filterComments(str classStr)
{
	//println(classStr);	 
	//filter multiline comments
	str before = classStr;
	
	int i = 1;
	
	// /<pre:[^]>\/\*<comment:.>\*\/<post:[^]>/
	//   /\\*(?:.|[\\n\\r])*?\\*/
	//	/<pre:.*>\/*<comment:.*>\/<post:.*>\*\//
	
	//  \/\/(.|\n)*
	
	//    (programma voor)\n(whitespace*)[/][/]<comment:(.*)>\n(programma na) 
	//	  volgenderonde = programma_voor + programma_na
	//
	
	
	while(/(<pre:.*?>\/\*<comment:.*>\*\/<post:.*?>)+/ := before)
	{
	    before = pre + post;
		println("Pre: <pre>");
		println("Comment:<comment>");
		println("Post: <post>");
	}
	//filter singleLine comments
	//while(/<pre:.>\/\/.?\n?<post:.>/ := before)
	 //before = pre + post;
	
	//filter excess whitespace	
	return before;
}

public void removeSingleLine(str comment){
	// /<pre:[^]>\/\*<comment:.>\*\/<post:[^]>/
	//   /\\*(?:.|[\\n\\r])*?\\*/
	//	/<pre:.*>\/*<comment:.*>\/<post:.*>\*\//
	
	//  \/\/(.|\n)*
	
	//    (programma voor)\n(whitespace*)[/][/]<comment:(.*)>\n(programma na) 
	//	  volgenderonde = programma_voor + programma_na
	//
	///<pre:.>\/\/.?\n?<post:.>\r\n/ := comment
	
	while(/<pre:\S>\/\/<post:.*>\r\n/ := comment)
	{
		comment = pre;
		println("var1: <var1>");
		println("var2: <var2>");
		println("var1: <comment>");
	}
}

public void volume(M3 model, set[Declaration] ast) 
{
	

	//Filter comments
	//model2 = filterComments(model);
	
	//Lines of code	
	
	//Number of units
}

public void unitSize(M3 model)
{
	
}

public void unitComplexity(M3 model)
{
	//Filter comments
	
}

public void duplication(M3 model)
{
	//strategy: for each 6 line of code, check if they appear elsewhere
}