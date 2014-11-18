module SIGmodel
import Prelude;
import String;
import IO;
import Math;

//Java Parsing libraries
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

//Utility Libraries
import SIGModelMetrics::Lib::StringCleaning;
import SIGModelMetrics::Lib::CodeCleaning;

//Metric Libraries
import SIGModelMetrics::OveralSize;
import SIGModelMetrics::UnitSize;

//lower system boundaries for ratings
map[str, int] systemSizeRankings = (
	"--" : 1310000,
	"-"	 : 655000,
	"o"  : 246000,
	"+"	 : 66000,
	"++" : 0
);

map[str, int] unitSizeRisk = (
	"Low" : 101,
	"Moderate" : 51,
	"High" : 21,
	"Very High" : 0
);

public void allMetrics(loc project)
{
	println("Calculating M3 model...");
	model = createM3FromEclipseProject(project);
	println("Done! Calculating Metrics:\r\n");
	//////////////////////////////////////////////////////////////
	println("===========  Overal Volume   ============");
	println("calculating lines of codes of project...\r\n");	
	
	linesOfCode = overalVolume(model);
	volumeRisk = overalVolumeRisk(linesOfCode);
	
	println("Total lines of code: <linesOfCode> 
	                \r\n Ranking: <volumeRisk>");
	//////////////////////////////////////////////////////////////
	println("===========    Unit Size     =============");	
	println("calculating size of units profile...\r\n");
	
	unitSizeDist = unitSizeMetric(model, linesOfCode);	
    
    println("Results : Low | Moderate | High | Very High");
    println("          <unitSizeDist[0]>% | <unitSizeDist[1]>% | <unitSizeDist[2]>% | <unitSizeDist[3]>% \r\n");
    
	//////////////////////////////////////////////////////////////
	println("=========== Unit Complexity  =============");
	println("Metric not yet implemented!");
	/*zet hier je complexity methode, alle println hier!*/
	//////////////////////////////////////////////////////////////
	println("=========== Code Duplication =============");	
	println("Metric not yet implemented!");
}
public int overalVolume(M3 model)
{	return projectLinesOfCode(model);}

public str overalVolumeRisk(int linesOfCode)
{
	for(rank <- ["--", "-", "o", "+", "++"])
	  if(linesOfCode > systemSizeRankings[rank])
	  	return rank;
}
public list[int] unitSizeMetric(model, totalLinesOfCode)
{
	map[str,int] unitSizes = unitSizes(model);
	r = calcRiskProfile(unitSizes);
	
	list[int] relRisk = [
		     				r["Low"], 		
		 	 				r["Moderate"], 	
						 	r["High"], 		
						 	r["Very High"] 
						 ];
						 
	return relRisk;	
}
public map[str,int] calcRiskProfile(map[str,int] unitLines)
{
	map[str,int] riskLines = (
		"Low" 	    : 0,
		"Moderate"  : 0,
		"High" 	    : 0,
		"Very High" : 0
	);
	
	for(method <- unitLines)
		for(risk <- ["Very High", "High", "Moderate", "Low"])
			if(unitLines[method] > unitSizeRisk[risk])
				riskLines += (risk : (riskLines[risk] + unitLines[method]));
	
	return riskLines;

}