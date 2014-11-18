module SIGmodel
import Prelude;
import String;
import IO;
import util::Math;

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
	
<<<<<<< HEAD
<<<<<<< HEAD
	unitSize = unitSizes(model);	
	unitLines = (0 | it + unitSize[e] | e <- unitSize );
=======
	unitSizes = unitSizes(model);
	unitLines = (0 | it + e | _:e <- unitSizes );
>>>>>>> parent of 095ec03... Jeff implementing CC in allMetrics
	
	unitSizeDist = catUnitSize(model, unitSizes);	
    
    println("Results : Low | Moderate | High | Very High");
    println("          <unitSizeDist[0]>% | 
    				   <unitSizeDist[1]>% | 
    				   <unitSizeDist[2]>% | 
    				   <unitSizeDist[3]>% \r\n");
    				   
=======
	map[loc,int] unitSizes = unitSizes(model);
	unitLines = (0 | it + unitSizes[e] | e <- unitSizes );
	
	unitSizeDist = catUnitSize(model, unitSizes);
	getUnitSizeRanking(unitSizeDist);	
>>>>>>> 9a3c61d8eb8e60c05d8f6d36393ac9d3532753b5
    
    println("Risk due to unit size:");
    println("Low       : <unitSizeDist[0]>%");
    println("Moderate  : <unitSizeDist[1]>%");
    println("High      : <unitSizeDist[2]>%");
    println("Very High : <unitSizeDist[3]>%\r\n");
    println("Ranking: ")
    				    
	//////////////////////////////////////////////////////////////
	println("=========== Unit Complexity  =============");
	println("Metric not yet implemented!");
	int comp = complexity(model, unitSizes, unitLines);
	//////////////////////////////////////////////////////////////
	println("=========== Code Duplication =============");	
	println("Metric not yet implemented!");
}

// Overal Volume /////////////////////////////////////////////////
map[str, int] systemSizeRankings = (
	"--" : 1310000,
	"-"	 : 655000,
	"o"  : 246000,
	"+"	 : 66000,
	"++" : 0
);

public int overalVolume(M3 model)
{	return projectLinesOfCode(model);}

public str overalVolumeRisk(int linesOfCode)
{
	for(rank <- ["--", "-", "o", "+", "++"])
	  if(linesOfCode > systemSizeRankings[rank])
	  	return rank;
}

// Unit Size /////////////////////////////////////////////////////
map[str, int] unitSizeRisk = (
	"Low" : 0,
	"Moderate" : 21,
	"High" : 51,
	"Very High" : 101
);

map[str, list[int]] unitSizeRank = (
	 "++" : [0,  0,  0],
	 "+"  : [26, 0,  0],
	 "o"  : [31, 6 , 0],
	 "-"  : [41, 11, 0],
	 "--" : [51, 15, 6]
	);

public list[int] catUnitSize(model, map[loc,int] unitSize)
{
<<<<<<< HEAD
	r = calcRiskProfile(unitSize);

=======
	r = calcRiskProfile(unitSizes);
>>>>>>> parent of 095ec03... Jeff implementing CC in allMetrics
	
	list[int] relRisk = 
		[
			round(r["Low"] 	     / (total*0.01)), 		
			round(r["Moderate"]  / (total*0.01)), 	
		 	round(r["High"] 	 / (total*0.01)), 		
		 	round(r["Very High"] / (total*0.01)) 
		];
						 
	return relRisk;	
}
<<<<<<< HEAD

public map[str,int] calcRiskProfile(map[loc,int] unitLines)
=======
public map[str,int] calcRiskProfile(map[str,int] unitLines)
>>>>>>> parent of 095ec03... Jeff implementing CC in allMetrics
{	
	map[str,int] riskLines = (
		"Low" 	    : 0,
		"Moderate"  : 0,
		"High" 	    : 0,
		"Very High" : 0
	);
	
	for(method <- unitLines)
		for(risk <- ["Very High", "High", "Moderate", "Low"])
			if(unitLines[method] >= unitSizeRisk[risk]){
				riskLines += (risk : (riskLines[risk] + unitLines[method]));
				break;
			}
	
	return riskLines;
}


<<<<<<< HEAD
=======
public map[str, real] testCaclCom(M3 model)
>>>>>>> parent of 095ec03... Jeff implementing CC in allMetrics
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

// Code Duplication //////////////////////////////////////////////
