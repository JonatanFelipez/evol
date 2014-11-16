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

public void unitSizeProject(loc project)
{
 	model =  createM3FromEclipseProject(project);
 	unitSizeMapping = unitSize(model);
 	
 	println("calculated size of methods!");	
}

public void unitSizeMetric(M3 model)
{
	println("============= Unit Size ==============");
	println("calculating size of units profile...\r\n");
	map[str,int] sizeOfUnits = unitSize(model);
	println("Metric not yet implemented!");
	
	
	/*
	println("Done! System risk due to overal volume:");
	if(linOCode > sizes["--"]){
		println("-- (very high)");
		println("Motivation: LoC (<linOCode>) bigger than " + sizeStr["--"] );}
	if(linOCode > sizes["-"]){
		println("- (high)");
		println("Motivation: LoC (<linOCode>) smaller than " + sizeStr["--"] );}
	if(linOCode > sizes["o"]){  
		println("o (medium)");
		println("Motivation: LoC (<linOCode>) smaller than " + sizeStr["-"] );}
	if(linOCode > sizes["+"]){  
		println("+ (low)");
		println("Motivation: LoC (<linOCode>) smaller than " + sizeStr["o"] );}
	if(linOCode > sizes["++"]) {
		println("++ (very low)");
		println("Motivation: LoC (<linOCode>) smaller than " + sizeStr["+"] );} 	
	*/
}

public map[str,int] unitSize(M3 model)
{
	set[loc] docloc = range(model@documentation); //location of all documentation in the project	
	set[loc] filelocs = files(model);

	//get all method declarations in the project
	methLocs = { dec | dec <- model@declarations, dec[0].scheme == "java+method"};
	 
	map[str, int] method2LoC = ();
	//map a method filepath to the line
	for(method <- methLocs)
	{
	  //get all documentation in the file that contains the method 
	  docsInFile = { doc | doc <- docloc, doc.path == method[1].path};
	  cleanMethod = filterDocInMethod(model, method[1], docsInFile, false);	 
	 
	  method2LoC = method2LoC + (method[0].path : size(split("\r\n", cleanMethod)));
	}	
	return method2LoC;
	
}