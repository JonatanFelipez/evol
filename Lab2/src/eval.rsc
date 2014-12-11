module eval

import Prelude;
import String;
import IO;

import CloneDetection;

//Java Parsing libraries
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;

@memo
//value getMyExampleData(int input)
alias testSetup = map[loc, measurements];
alias measurements = map[str, int];



public bool AutoTest()
{	
					/*measurements measurement = ("%dupLoc" : 0, 
									"totalLoc" : 0,
									"dupLoc" : 0,
									"numClones" : 0,
									"numClasses" : 0,
									"biggestClone" : 0,
									"biggestClass" : 0									
									);*/
	try	{					
	
		map[loc, measurements] testLocations = (|project://smallsql| : (
																		"%dupLoc" : 4, 
																		"totalLoc" : 22210,
																		"dupLoc" : 956,
																		"numClones" : 116,
																		"numClasses" : 47),
												|project://ExactClones| : (
																		"%dupLoc" : 62, 
																		"totalLoc" : 32,
																		"dupLoc" : 20,
																		"numClones" : 2,
																		"numClasses" : 1),
												|project://testproject| : (
																		"%dupLoc" : 55, 
																		"totalLoc" : 72,
																		"dupLoc" : 40,
																		"numClones" : 5,
																		"numClasses" : 2));
	
		for(location <- testLocations)
		{
			println("starting test for: <location.uri>");
			
			println("creating M3");
			model = createM3FromEclipseProject(location);
			
			println("creating AST");
			AST = createAstsFromEclipseProject(model.id, false);
			
			results = run(AST, 6, false);
			
			//assert results["%dupLoc"] == testLocations[location][""%dupLoc""] : "dup % not equal";
			/*%dupLoc" : 4, 
																		"totalLoc" : 22210,
																		"dupLoc" : 956,
																		"numClones" : 116,
																		"numClasses" : 47*/
			/*//Check each test
			assert test_sizeOfTree == size(methods(model)) : "Unit Complexity: total amount of evaluated methods (<countConst + countMethods + countMet2>) does not equal total amount of methods (<size(methods(model))>)";		
			test_sizeOfTree(state, numberOfNodes);
			test_testCloneDetection();
			test_groupClones(buckets);
			test_bucketSortDecl(model, threshold);
			test_ripStatements(state);
			test_bucketSortStat(AST, threshold);
			test_getStatementSequences(methodName1, AST, threshold);
			test_bucketSortSequence(methodName, AST, threshold);*/
			
			
		}
		return true;
	}catch exp : println("During testing, there was a error: <exp>");
}


public bool test_sizeOfTree(Statement state, int numberOfNodes)
{
	return sizeOfTree(state) == numberOfNodes;
}

public bool test_testCloneDetection()
{
	testCloneDetection();
	return true;
}

public bool test_groupClones(map[str, set[Declaration]] buckets)
{
	groupClones(buckets);
	return true;
}

public bool test_bucketSortDecl(M3 model, int threshold)
{
	bucketSortDecl( model, threshold);
	return true;
}

public bool test_ripStatements(Statement state)
{
	ripStatements(state);
	return true;
}

public bool test_bucketSortStat(set[Declaration] AST, int threshold)
{
	println("checking the bucketSortStat....");
	visit(AST)
	{
		case x: \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{bucketSortStat(impl,threshold);}
	}
	return true;
}

public bool test_getStatementSequences(str methodName1,  set[Declaration] AST, int threshold)
{
	println("checking the getStatementSequences....");
	
	visit(AST)
	{
		case x: \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{if(methodName == name) return ripStatement(impl, threshold);}
	}
	
}

public bool test_bucketSortSequence(str methodName, set[Declaration] AST, int threshold)
{
	println("checking the bucketSortSequence....");
	
	visit(AST)
	{
		case x: \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{if(methodName == name) bucketSortSequence(impl, threshold);}
	}
	
}
