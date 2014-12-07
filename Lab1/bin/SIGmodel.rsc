		qqmodule SIGmodel
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
import Config;

//Metric Libraries
import SIGModelMetrics::OveralSize;
import SIGModelMetrics::UnitSize;
import SIGModelMetrics::UnitComplexity;
import SIGModelMetrics::Duplication;


public void allMetrics(loc project)
{
	println("Calculating M3 model...");
	model = createM3FromEclipseProject(project);
	println("Calculating Metrics...\r\n");
	//////////////////////////////////////////////////////////////
	println("===========  Overal Volume   ============");
	println("calculating lines of codes of project...\r\n");	
	
	linesOfCode = overalVolume(model);
	volumeRisk = overalVolumeRisk(linesOfCode);
	
	println("Total lines of code: <linesOfCode> 
	                \r\n Ranking: <volumeRisk>\r\n");
	//////////////////////////////////////////////////////////////
	println("===========    Unit Size     =============");	
	println("calculating unit size Risk profile...\r\n");
	
	//Get a mapping from method to the cnt of lines of code
	map[loc,int] unitSizes = unitSizes(model);	
    
    //Calculate the total number of lines in all methods 
	unitLines = (0 | it + unitSizes[e] | e <- unitSizes );
    
	//Partition lines of code in level of risk (Low, Moderate, High, Very High)
	unitSizeDist = catUnitSize(model, unitSizes);	
    
    //Calculate the rank given by the SIG.  
    rank = unitSizeRanking(unitSizeDist);
    
    println("Risk due to unit size:");
    println("Low       : <unitSizeDist[0]>%");
    println("Moderate  : <unitSizeDist[1]>%");
    println("High      : <unitSizeDist[2]>%");
    println("Very High : <unitSizeDist[3]>%\r\n");
    println(" Ranking: <rank>\r\n");
    				    
	//////////////////////////////////////////////////////////////
	println("=========== Unit Complexity  =============");
	overalComplexity = complexity(model, unitSizes);
	
	complexityProcentage= calcComplexity(overalComplexity, unitLines);
	complexityRisk = overalComplexityRisk(complexityProcentage);
	
    println("\r\nRisk due to unit complexity:");
    println("Low       : <round(complexityProcentage["Low"])>%");
    println("Moderate  : <round(complexityProcentage["Moderate"])>%");
    println("High      : <round(complexityProcentage["High"])>%");
    println("Very High : <round(complexityProcentage["Very High"])>%\r\n");
    println(" Ranking: <complexityRisk>\r\n");

	//////////////////////////////////////////////////////////////
	println("=========== Code Duplication =============");	
	percentage = duplicatedPercentage(model, linesOfCode);
	println("Amount of code duplication: <round(percentage)>%");
	duplicationRanking = calcDuplicatedRank(percentage);
	println(" Ranking: <duplicationRanking>\r\n");
	
	//////////////////////////////////////////////////////////////
	println("===========     Overall      =============");
	
	map[str, str] overallResults = (
	"volume" : 	   volumeRisk, 
	"complexity" : complexityRisk,
	"duplication": duplicationRanking,
	"unitSize": 	rank
	);
	
	res = calcMaintainability(overallResults);
}

// Overal Volume /////////////////////////////////////////////////
public int overalVolume(M3 model)
{return projectLinesOfCode(model);}

public str overalVolumeRisk(int linesOfCode)
{
	for(rank <- ["--", "-", "o", "+", "++"])
	  if(linesOfCode > systemSizeRankings[rank])
	  	return rank;
}

// Unit Size /////////////////////////////////////////////////////
public list[int] catUnitSize(model, map[loc,int] unitSize)
{
	r = calcRiskProfile(unitSize);	
	total = (0 | it + r[e] | e <- r);	
	
	list[int] relRisk = 
		[
			round(r["Low"] 	     / (total*0.01)), 		
			round(r["Moderate"]  / (total*0.01)), 	
		 	round(r["High"] 	 / (total*0.01)), 		
		 	round(r["Very High"] / (total*0.01)) 
		];						 
	return relRisk;	
}
public str unitSizeRanking(list[int] sizeRisk)
{
	for(k <- ["--", "-", "o", "+"])
  		if(sizeRisk[1] > unitSizeRank[k][0] ||
  		   sizeRisk[2] > unitSizeRank[k][1] ||
  		   sizeRisk[3] > unitSizeRank[k][2] 
  		   )
		   return k;
	return "++";
}

public map[str,int] calcRiskProfile(map[loc,int] unitLines)
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

// Unit Complexity  //////////////////////////////////////////////
public map[str, real] testCaclCom(M3 model)
{
	k = testComplexity(model);
	unitLines = (0 | it + k[e] | e <- k);
	return calcComplexity(k, unitLines);
}

public str overalComplexityRisk(map[str, real]complexityprec)
{
	for(rank <- ["--", "-", "o", "+"])
  		if(complexityprec["Moderate"]  > systemComplexityRankings[rank]["Moderate"] ||
  		   complexityprec["High"]      > systemComplexityRankings[rank]["High"] 	||
		   complexityprec["Very High"] > systemComplexityRankings[rank]["Very High"] 
		)
  			return rank;
  			
	return "++";
}

public map[str, real] calcComplexity(map[str, int] complexityLines, int totalLines)
{
	map[str, real] percentages = ();
	
	for(x <- complexityLines)
		{percentages[x] = complexityLines[x] / (totalLines / 1.0) * 100 ;}
		
	return percentages;
}

// Code Duplication //////////////////////////////////////////////
public str calcDuplicatedRank(real percentage)
{
	for(r <- ["++", "+", "o", "-"])
		if(percentage < duplicatedRank[r])
			return r;
 	return "--";
}
// Maintainability ///////////////////////////////////////////////		
map[str, str] calcMaintainability(map[str, str] overallResults)
{
	ranks = ["++", "+", "o", "-"];

	map[str, str] results = (
	"Analysability"  : "--",
	"Changeability"  : "--",	
	"Testability"    : "--"	
	); //"Stability" : "--",
	
	//========Analysability==========
	Analysability = (resultsValues[overallResults["volume"]] + 
					 resultsValues[overallResults["duplication"]] + 
					 resultsValues[overallResults["unitSize"]]) / 3;	
	 
	 for(x <- ranks)
	 	if(Analysability >= resultsValues[x])
	 	{
	 		results["Analysability"] = x;
	 		break;
		}
	//========Changeability==========
	Changeability = (resultsValues[overallResults["complexity"]] + 
					resultsValues[overallResults["duplication"]]) / 2;

	 for(x <- ranks)
	 	if(Changeability >= resultsValues[x])
	 	{
	 		results["Changeability"] = x;
	 		break;
		}
	//========Testability==========
	Testability = (resultsValues[overallResults["complexity"]] + 
				  resultsValues[overallResults["unitSize"]]) / 2; //unit testing

	 for(x <- ranks)
	 	if(Changeability >= resultsValues[x])
	 	{
	 		results["Testability"] = x;
	 		break;
		}
				 	
	println("Analysability: <results["Analysability"]> (Volume, Duplication, Unit Size)");
	println("Changeability: <results["Changeability"]> (Unit Complexity, Duplication)");
	println("Testability:   <results["Testability"] > (Unit Complexity, Unit Size)\r\n");
	
	 avgMaintVal = (Analysability + Changeability + Testability) / 3.0;
	 avgMaint = "--";
	 for(x <- ranks)
	 	if(avgMaintVal >= resultsValues[x])
	 	{
	 		avgMaint = x;
	 		break;
		}
	
	println("Overall Maintainability: <avgMaint>");
	
	return results;
}