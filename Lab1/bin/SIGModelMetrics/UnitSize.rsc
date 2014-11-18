module SIGModelMetrics::UnitSize
import Prelude;
import String;
import IO;

//Java Parsing libraries
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

//Utility Libraries
import SIGModelMetrics::Lib::StringCleaning;
import SIGModelMetrics::Lib::CodeCleaning;

//Dependency on other metrics
import SIGModelMetrics::OveralSize;

public void unitSizeProject(loc project)
{
 	model =  createM3FromEclipseProject(project);
 	unitSizes(model);
}

public map[loc,int] unitSizes(M3 model)
{
	set[loc] docloc = range(model@documentation); //location of all documentation in the project	
	set[loc] filelocs = files(model);

	//get all method declarations in the project
	
	methLocs = { methods | classes <- classes(model) dec <- model@declarations, dec[0].scheme == "java+method"};
	 
	map[loc, int] method2LoC = ();
	
	for(method <- methLocs)
	{
	  //get all documentation in the file that contains the method 
	  docsInFile = { doc | doc <- docloc, doc.path == method.path};
	  cleanMethod = filterDocInMethod(model, method, docsInFile, false);	 
	 
	  method2LoC = method2LoC + (method : size(split("\r\n", cleanMethod)));
	}
	debug(method2LoC);	
		
	return method2LoC;	
}

public void debug(map[loc, int] arg)
{
	for(x <- arg)
	 if(arg[x] < 10 && x.end[0] - x.begin[0] != arg[x])
	 {
	 	println("lines: <arg[x]>");
	 	println("location: <x>");
	 }
}








