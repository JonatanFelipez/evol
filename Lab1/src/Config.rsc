module Config

// Volume ///////////////////////////////////////////////
public map[str, int] systemSizeRankings = (
	"--" : 1310000,
	"-"	 : 655000,
	"o"  : 246000,
	"+"	 : 66000,
	"++" : 0
);

// Unit Size //////////////////////////////////////////////
public map[str, int] unitSizeRisk = (
	"Low" 	    : 0,
	"Moderate"  : 21,
	"High"      : 51,
	"Very High" : 101
);

public map[str, list[int]] unitSizeRank = (
	 "++" : [0,  0,  0],
	 "+"  : [25, 0,  0],
	 "o"  : [30, 5 , 0],
	 "-"  : [40, 10, 0],
	 "--" : [50, 15, 5]
	);

// Unit Complexity /////////////////////////////////////////
public map[str, map[str, real]] systemComplexityRankings = (
	"--" : ("Moderate" : 50.0, "High" : 15.0, "Very High" : 5.0 ),
	"-"	 : ("Moderate" : 40.0, "High" : 10.0, "Very High" : 0.0 ),
	"o"  : ("Moderate" : 30.0, "High" : 5.0,  "Very High" : 0.0 ),
	"+"	 : ("Moderate" : 25.0, "High" : 0.0,  "Very High" : 0.0 ),
	"++" : ("Moderate" : 0.0,  "High" : 0.0,  "Very High" : 0.0 )
);

// Code Duplication /////////////////////////////////////////
public map[str, int] duplicatedRank = (
	 "++" : 3,
	 "+"  : 5,
	 "o"  : 10,
	 "-"  : 20,
	 "--" : 100
	);

// Overal Maintainability ///////////////////////////////////
public map[str, real] resultsValues = (
	"++" : 4.0,
	"+"  : 3.0,
	"o"  : 2.0,
	"-"  : 1.0,
	"--" : 0.0
	);	
	