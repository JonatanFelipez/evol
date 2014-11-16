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

public void volumeProject(loc project)
{
 	model =  createM3FromEclipseProject(project);
 	overalVolumeMetric(model);	
}

public void overalVolumeMetric(M3 projectModel)
{
	println("calculating lines of codes of project...");	
	
	linOCode = projectLinesOfCode(projectModel); 
	
	println("Done!");
	println("total lines of code: <linOCode>");
	
	println("System risk due to overal volume:");
	if(linOCode > sizes["--"]) println("-- (very high)");
	if(linOCode > sizes["-"])  println("-- (high)");
	if(linOCode > sizes["o"])  println("-- (medium)");
	if(linOCode > sizes["+"])  println("-- (low)");
	if(linOCode > sizes["++"]) println("-- (very low)");	
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