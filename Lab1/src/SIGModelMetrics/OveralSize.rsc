module SIGModelMetrics::OveralSize
import Prelude;
import String;

//Java Parsing libraries
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

//Utility Libraries
import SIGModelMetrics::Lib::StringCleaning;
import SIGModelMetrics::Lib::CodeCleaning;

//lower system boundaries for ratings
map[str, int] sizes = (
	"--" : 1310000,
	"-"	 : 655000,
	"o"  : 246000,
	"+"	 : 66000,
	"++" : 0
);

map[str, str] sizeStr = (
	"--" : "1310000",
	"-"	 : "655000",
	"o"  : "246000",
	"+"	 : "66000",
	"++" : "0"
);

public void volumeProject(loc project)
{
 	model =  createM3FromEclipseProject(project);
 	overalVolumeMetric(model);	
}

public void overalVolumeMetric(M3 projectModel)
{
	println("=========== Overal Volume ============");
	println("calculating lines of codes of project...\r\n");	

	linOCode = projectLinesOfCode(projectModel); 
	
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
}

private int projectLinesOfCode(M3 model)
{
	set[loc] files  = files(model);	//location of all the files in the project
	set[loc] docLoc = range(model@documentation); //location of all the documentation in the project
    
    int totalLines = 0; 
    
    //calculate the lines of code for each file  
    for(file <- files)
    {	 
    	//filter all comments that are not in the file   
    	docsInFile = {doc | doc <- docLoc, file.path == doc.path};
    	//clean the comments out of the sourcecode, and filter empty lines
    	cleanFile = filterDocInFile(model, file, docsInFile);
    	//add the linecount of the cleaned file to the total
    	totalLines = totalLines + size(split("\r\n", cleanFile));	
    }
    return totalLines;
}