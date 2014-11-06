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
	
	//ast = createAstsFromEclipseProject(project, true);
	//volume(model, ast);
	
	docSections = model@documentation;
	
} 

public M3 makeModel()
{
	return createM3FromEclipseProject(project);
}

public int countLinesOfClass(loc classLoc)
{
	linesInClass = readFileLines(classLoc);
	
	return size(filterComments(linesInClass));
}

public M3 filterComments(list[str] lines)
{
	return model;
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