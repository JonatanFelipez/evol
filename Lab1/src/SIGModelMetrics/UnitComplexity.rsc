module SIGModelMetrics::UnitComplexity

import SIGModelMetrics::OveralSize;
import SIGModelMetrics::UnitSize;
import Prelude;
import String;

//Java Parsing libraries
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;

/*M = E- N + P or CC = number of decisions + 1
  M = complexity
  E = number of edges
  P = number of nodes that have exit points(predicated notes)*/
  
  /*Cyclomatic complexity is a source code complexity measurement
   that is being correlated to a number of coding errors.
    It is calculated by developing a Control Flow Graph of the code
    that measures the number of linearly-independent paths through a program module.*/
    
 /*Linearly-independent paths = a complete path which, disregarding back tracking (such as loops), 
 	has an unique set of decisions in a program. */ 	

map[str, int] unitComplexityRisk = (
	"Low" : 0,
	"Moderate" : 10,
	"High" : 20,
	"Very High" : 50
);

public map[str, int] testComplexity(M3 model)
{
	return complexity(model, unitSizes(model));	
}

public map[str, int] complexity(M3 model, map[loc,int]unitSizes){

	map[str, int] complexityLines = (
		"Low" : 0,
		"Moderate" : 0,
		"High" : 0,
		"Very High" : 0
	);
	
	int cnt = 0;
	set[Declaration] decls = createAstsFromEclipseProject(model.id, true); //need a tree to look for statements and declarations
	int countMethods= 0;
	int countConst = 0;
	int countMet2 = 0;
	set[loc] locations ={};
		
	visit(decls){
		case m: \method(_,_,_,_, Statement impl):{							
			
			methodSize = unitSizes[m@src];			
			cnt = countComplexity(impl, 50);				
			countMethods += 1;		
			for(x <- ["Very High", "High", "Moderate", "Low"])
				if(cnt > unitComplexityRisk[x]){					
					complexityLines[x] += methodSize;
					break;
					}	
			} 
		case m2: \method(_,_,_,_):{method2Size = unitSizes[m2@src]; complexityLines["Low"] += method2Size;}
		case c: \constructor(_,_,_, Statement impl):{			
				
				ConstructorSize = unitSizes[c@src];				
				cnt = countComplexity(impl, 50);
				countConst += 1;	
				
				for(x <- ["Very High", "High", "Moderate", "Low"])
				if(cnt > unitComplexityRisk[x]){					
					complexityLines[x] += ConstructorSize;
					break;
					}	
				}				 				
	}
	
	assert countConst + countMethods + countMet2 == size(methods(model)) : "Unit Complexity: total amount of evaluated methods (<countConst + countMethods + countMet2>) does not equal total amount of methods (<size(methods(model))>)";
	return complexityLines;	
}

//This method calculates the complexity of the statement is is given.
//this method uses the CC= number of decisions + 1 formula to calculate complexity.
int countComplexity(Statement stat, int limit)
{
	int cnt = 1; //using CC = number of decisions + 1 (its the reason we start with 1)
	
	 visit(stat){
	 	//Decision making statements
		case \if(Expression condition, _):  //if
			if(cnt > limit) {return cnt;}else{cnt += countCondition(condition);}			
		case \if(Expression condition, _, _): //if-else
			if(cnt > limit) {return cnt;}else{cnt += countCondition(condition);}
		case \case(_):  //switch-case
			if(cnt > limit){return cnt;}else{cnt+=1;}
		
		//Loop statements
		case \while(Expression condition,_): //while 
			if(cnt > limit) {return cnt;}else{cnt += countCondition(condition);}		 
		case \for(_,_,_,_): //normal for
			if(cnt > limit){return cnt;}else{cnt+=1;}			 
		case \for(_,_,_): //enhanced for
			if(cnt > limit){return cnt;}else{cnt+=1;}
		case \do(_, Expression condition): //do
			if(cnt > limit) {return cnt;}else{cnt += countCondition(condition);}	
		
		//Exception statements
		case \try(_,_): //try-catch
			if(cnt > limit){return cnt;}else{cnt+=1;}
 		case \try(_,_,_): //try-catch-finally
 			if(cnt > limit){return cnt;}else{cnt+=1;}
		case \throw(_): //throw
			if(cnt > limit) {return cnt;}else{cnt += countCondition(condition);}		
	}
	
	assert cnt > 0 : "Unit Complexity: cnt is smaller then one";
	assert limit > 0 : "Unit Complexity: limit is zero";
	
	return cnt;
}

//This method counts the conditions in statements with expressions
// for example: if(a>b && b>c){} the result from this statement = 2.
int countCondition(Expression condition)
{
	int cnt = 0;
	
	top-down-break visit(condition){
		case \infix(_,str operator, Expression rhs): 
			cnt += 1 + countCondition(rhs);
	}	
	
	return cnt;
}
