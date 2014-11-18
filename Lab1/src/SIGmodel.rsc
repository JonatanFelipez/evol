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
import SIGModelMetrics::UnitComplexity;

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
	                \r\n Ranking: <volumeRisk>\r\n");
	//////////////////////////////////////////////////////////////
	println("===========    Unit Size     =============");	
	println("calculating size of units profile...\r\n");
	
	unitSizes = unitSizes(model);
	unitLines = (0 | it + e | _:e <- unitSizes );
	
	unitSizeDist = catUnitSize(model, unitSizes);	
    
    println("Results : Low | Moderate | High | Very High");
    println("          <unitSizeDist[0]>% | 
    				   <unitSizeDist[1]>% | 
    				   <unitSizeDist[2]>% | 
    				   <unitSizeDist[3]>% \r\n");
    				   
    
	//////////////////////////////////////////////////////////////
	println("=========== Unit Complexity  =============");
	println("Metric not yet implemented!");
	int comp = complexity(model, unitSizes, unitLines);
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
public list[int] catUnitSize(model, map[loc,int] unitSize)
{
	r = calcRiskProfile(unitSizes);
	
	list[int] relRisk = 
		[
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


public map[str, real] testCaclCom(M3 model)
{
	k = testComplexity(model);
	unitLines = (0 | it + k[e] | e <- k);
	return calcComplexity(k, unitLines);
}

map[str, map[str, real]] systemComplexityRankings = (
	"--" : ("Moderate" : 51.0, "High" : 16.0, "Very High" : 6.0 ),
	"-"	 : ("Moderate" : 41.0, "High" : 11.0, "Very High" : 0.0 ),
	"o"  : ("Moderate" : 31.0, "High" : 6.0, "Very High" : 0.0 ),
	"+"	 : ("Moderate" : 26.0, "High" : 0.0, "Very High" : 0.0 ),
	"++" : ("Moderate" : 0.0, "High" : 0.0, "Very High" : 0.0 )
);

public str overalComplexityRisk(map[str, real]complexityprec)
{
	for(rank <- ["--", "-", "o", "+", "++"])
  		if(complexityprec["Moderate"] >= systemComplexityRankings[rank]["Moderate"] &&
  		   complexityprec["High"] >= systemComplexityRankings[rank]["High"] &&
		   complexityprec["Very High"] >= systemComplexityRankings[rank]["Very High"] 
		)
  			return rank;
  			
	return "Error: overalComplexityRisk";
}

public map[str, real] calcComplexity(map[str, int] complexityLines, int totalLines)
{
	map[str, real] percentages = ();		
	
	for(x <- complexityLines)
		{percentages[x] = complexityLines[x] / (totalLines / 1.0) * 100 ;}
		
	return percentages;
}