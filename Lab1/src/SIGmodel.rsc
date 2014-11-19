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
	println("calculating size of units profile...\r\n");
	
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
	println("calculating unit complexity...\r\n");	
	overalComplexity = complexity(model, unitSizes);
	
	complexityProcentage= calcComplexity(overalComplexity, unitLines);
	complexityRisk = overalComplexityRisk(complexityProcentage);
	
    println("Risk due to unit size:");
    println("Low       : <complexityProcentage["Low"]>%");
    println("Moderate  : <complexityProcentage["Moderate"]>%");
    println("High      : <complexityProcentage["High"]>%");
    println("Very High : <complexityProcentage["Very High"]>%\r\n");
    println(" Ranking: <rank>\r\n");

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
{return projectLinesOfCode(model);}

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
	 "+"  : [25, 0,  0],
	 "o"  : [30, 5 , 0],
	 "-"  : [40, 10, 0],
	 "--" : [50, 15, 5]
	);

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
map[str, map[str, real]] systemComplexityRankings = (
	"--" : ("Moderate" : 50.0, "High" : 15.0, "Very High" : 5.0 ),
	"-"	 : ("Moderate" : 40.0, "High" : 10.0, "Very High" : 0.0 ),
	"o"  : ("Moderate" : 30.0, "High" : 5.0,  "Very High" : 0.0 ),
	"+"	 : ("Moderate" : 25.0, "High" : 0.0,  "Very High" : 0.0 ),
	"++" : ("Moderate" : 0.0,  "High" : 0.0,  "Very High" : 0.0 )
);


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
	total = (0 | it + complexityLines[e] | e <- complexityLines);		
	
	for(x <- complexityLines)
		{percentages[x] = complexityLines[x] / (total / 1.0) * 100 ;}
		
	println("totalLines: <totalLines>");
	println("total: <total>");		
	return percentages;
}

// Code Duplication //////////////////////////////////////////////
