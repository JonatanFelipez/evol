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
		
	visit(decls){
		case m: \method(_,_,_,_, Statement impl):{							
			methodSize = unitSizes[m@src];
			cnt = countComplexity(impl, 50);				
								
			for(x <- ["Very High", "High", "Moderate", "Low"])
				if(cnt > unitComplexityRisk[x]){					
					complexityLines[x] = complexityLines[x] + methodSize;
					}	
			} 
		case c: \constructor(_,_,_, Statement impl, 50):{			
				methodeSize = unitSizes[c@src];
				cnt = countComplexity(impl, 50);
				
				for(x <- ["Very High", "High", "Moderate", "Low"])
				if(cnt > unitComplexityRisk[x]){					
					complexityLines[x] = complexityLines[x] + methodSize;
					}	
				}				 				
	}	
	return complexityLines;
}

//This method calculates the complexity of the statement is is given.
//this method uses the CC= number of decisions + 1 formula to calculate complexity.
int countComplexity(Statement stat, int limit)
{
	int cnt = 1; //using CC = number of decisions + 1 (its the reason we start with 1)
	
	 visit(stat){
		case \if(Expression condition, _):  
			if(cnt > limit) {return cnt;}else{cnt += countCondition(condition);}			
		case \if(Expression condition, _, _): 
			if(cnt > limit) {return cnt;}else{cnt += countCondition(condition);}
		case \while(Expression condition,_): //should a while loop really be here. Only reason i can think off is because a while can have multible conditions 
			if(cnt > limit) {return cnt;}else{cnt += countCondition(condition);}
		case \case(_): // is a switch really that hard to understand? maybe only a risk if the number of cases in a switch exceeds a limit? 
			if(cnt > limit){return cnt;}else{cnt+=1;} 
		case \for(_,_,_,_): //should a for loop really be here (machine code or  Assembly will use a Jump, bne, branch on equal not if statements) it does have one condition
			if(cnt > limit){return cnt;}else{cnt+=1;}			 
		case \for(_,_,_): //should a for loop really be here (machine code or  Assembly will use a Jump, bne, branch on equal not if statements) it does have one condition
			if(cnt > limit){return cnt;}else{cnt+=1;}
		case \foreach(_, Expression condition, _):
			if(cnt > limit) {return cnt;}else{cnt += countCondition(condition);}
	}
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
