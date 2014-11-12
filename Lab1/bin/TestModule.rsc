module TestModule

import Prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

import IO;
import String;

//project location
loc project = |project://smallsql|;

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

public int countLinesOfClass(loc classLoc)
{
	classStr = readFile(classLoc);
	
	filterComments(classStr);
	
	return size(filterComments(linesInClass));
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