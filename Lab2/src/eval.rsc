module eval

import Prelude;
import String;

import CloneDetection;

//Java Parsing libraries
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;

@memo
value getMyExampleData(int input) = ...;

public test bool test_getAST()
{
 	getAST();
 	return true;
}

public test bool test_testCloneDetection()
{
	testCloneDetection();
	return true;
}

public test bool test_groupClones(map[str, set[Declaration]] buckets)
{
	groupClones(buckets);
	return true;
}

public test bool test_bucketSortDecl(M3 model, int threshold)
{
	bucketSortDecl( model, threshold);
	return true;
}

test bool test_ripStatements(Statement state)
{
	ripStatements(state);
	return true;
}
