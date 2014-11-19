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

public void testUnitSizeProject(loc project)
{
 	model =  createM3FromEclipseProject(project);
 	unitSizes(model);
}

public map[loc,int] unitSizes(M3 model)
{
	set[loc] docloc = range(model@documentation); //location of all documentation in the project	
	set[loc] filelocs = files(model);

	//get all method declarations in the project
	methLocs = { dec[1] | dec <- model@declarations, dec[0].scheme == "java+method" || dec[0].scheme == "java+constructor"};
	methList = [];
	for(c <- classes(model))
		for(m <- methods(model, c))
			methList += m;			
	
	map[loc, int] method2LoC = ();
	
	for(method <- methLocs)
	{
	  //get all documentation in the file that contains the method 
	  docsInFile = { doc | doc <- docloc, doc.path == method.path};
	  cleanMethod = filterDocInMethod(method, docsInFile, false);	 
	 
	  method2LoC[method] = size(split("\r\n", cleanMethod));
	}
		
	return method2LoC;	
}








