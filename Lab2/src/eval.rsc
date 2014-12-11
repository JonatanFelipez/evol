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
alias testSetup = map[set[Declaration] AST, measurements measurement];
alias measurements = map[str name, value _value];

public bool allAutoTest(set[Declaration] AST)
{
	try	{
	//create/read file with test
	testSetup setup = (AST : ("hallo": 6, "dit" : "is"));
	appendToFile(|project://Lab2/Tests/cloneDetectionTest.txt|, setup);
	appendToFile(|project://Lab2/Tests/cloneDetectionTest.txt|, "\r\n");
	//validated the AST
	
	//validated the answers
	
	//check all methods
	
	//print results
	
	//return true or false make modifier(void) to test.
		return true; 
		int a = 0;
	}catch exp : println("During the autotest, a error occured: <exp>"); return false;	
}

public void readAutoTests()
{
		//list[testSetup]
	iprint(readFileLines(|project://Lab2/Tests/cloneDetectionTest.txt|));
	list[str] lines = readFileLines(|project://Lab2/Tests/cloneDetectionTest.txt|);
	list[testSetup] setups = [];
	map[str name, value _value] measurements = ();
	
	for(line <- lines)
	{	
		list[str] splitLine = split(":", line);
		set[Declaration] AST = createAstsFromEclipseProject(createM3FromEclipseProject(toLocation(line[0]), false));				
	}
}

//Simply add new test units to the autoTest
private bool addAutoTest(loc projectLoc, testSetup setup)
{
	try	{
		//create/read file with test		
		appendToFile(|project://Lab2/Tests/cloneDetectionTest.txt|, setup); //append the test to the file.
		appendToFile(|project://Lab2/Tests/cloneDetectionTest.txt|, "\r\n"); //to put each test on a new line.
		return true;
	}catch exp: println(exp); return false;
}

public test bool test_sizeOfTree(Statement state, int numberOfNodes)
{
	return sizeOfTree(state) == numberOfNodes;
}

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

test bool test_bucketSortStat(set[Declaration] AST, int threshold)
{
	println("checking the bucketSortStat....");
	visit(AST)
	{
		case x: \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{bucketSortStat(impl,threshold);}
	}
	return true;
}

public list[list[list[Statement]]] test_getStatementSequences(str methodName1,  set[Declaration] AST, int threshold)
{
	println("checking the getStatementSequences....");
	
	visit(AST)
	{
		case x: \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{if(methodName == name) return ripStatement(impl, threshold);}
	}
	
}

public void test_bucketSortSequence(str methodName, set[Declaration] AST, int threshold)
{
	println("checking the bucketSortSequence....");
	
	visit(AST)
	{
		case x: \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{if(methodName == name) bucketSortSequence(impl, threshold);}
	}
	
}

public Statement visitingDeclarations(set[Declaration] AST)
{
	visit(AST){
	   case x: \compilationUnit(list[Declaration] imports, list[Declaration] types):{;}
	   case x: \compilationUnit(Declaration package, list[Declaration] imports, list[Declaration] types):{;}
	   case x: \enum(str name, list[Type] implements, list[Declaration] constants, list[Declaration] body):{;}
	   case x: \enumConstant(str name, list[Expression] arguments, Declaration class):{for(a<-arguments){visitingExpressions(a)};}
	   case x: \enumConstant(str name, list[Expression] arguments):{for(a<-arguments){visitingExpressions(a)};}
	   case x: \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{;}
	   case x: \class(list[Declaration] body):{;}
	   case x: \interface(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{;}
	   case x: \field(Type \type, list[Expression] fragments):{for(a<-fragments){visitingExpressions(a)};}
	   case x: \initializer(Statement initializerBody):{visitingStatements(initializerBody);}
	   case x: \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{for(a<-exceptions){visitingExpressions(a)}; visitingStatements(impl); return impl;}
	   case x: \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions):{for(a<-exceptions){visitingExpressions(a)};}
	   case x: \constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{for(a<-exceptions){visitingExpressions(a)}; visitingStatements(impl);}
	   case x: \import(str name):{;}
	   case x: \package(str name):{;}
	   case x: \package(Declaration parentPackage, str name):{;}
	   case x: \variables(Type \type, list[Expression] \fragments):{for(a<-\fragments){visitingExpressions(a)};;}
	   case x: \typeParameter(str name, list[Type] extendsList):{;}
	   case x: \annotationType(str name, list[Declaration] body):{;}
	   case x: \annotationTypeMember(Type \type, str name):{;}
	   case x: \annotationTypeMember(Type \type, str name, Expression defaultBlock):{visitingExpressions(defaultBlock);}
	   case x: \parameter(Type \type, str name, int extraDimensions):{;}
	   case x: \vararg(Type \type, str name):{;}
	}
}

public void visitingStatements(Statement state)
{
	visit(state){
		case x: \assert(Expression expression):{visitingExpressions(expression);}
	    case x: \assert(Expression expression, Expression message):{visitingExpressions(expression); visitingExpressions(message);}
	    case x: \block(list[Statement] statements):{;}
	    case x: \break():{;}
	    case x: \break(str label):{;}
	    case x: \continue():{;}
	    case x: \continue(str label):{;}
	    case x: \do(Statement body, Expression condition):{visitingExpressions(condition);}
	    case x: \empty():{;}
	    case x: \foreach(Declaration parameter, Expression collection, Statement body):{visitingExpressions(collection);}
	    case x: \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body):{for(e <- initializers){visitingExpressions(e);} visitingExpressions(condition); for(u <- updaters){visitingExpressions(u);}}
	    case x: \for(list[Expression] initializers, list[Expression] updaters, Statement body):{for(e <- initializers){visitingExpressions(e);} for(u <- updaters){visitingExpressions(u);}}
	    case x: \if(Expression condition, Statement thenBranch):{visitingExpressions(condition); iprint(x);}
	    case x: \if(Expression condition, Statement thenBranch, Statement elseBranch):{visitingExpressions(condition);}
	    case x: \label(str name, Statement body):{;}
	    case x: \return(Expression expression):{visitingExpressions(expression);}
	    case x: \return():{;}
	    case x: \switch(Expression expression, list[Statement] statements):{visitingExpressions(expression);}
	    case x: \case(Expression expression):{visitingExpressions(expression);}
	    case x: \defaultCase():{;}
	    case x: \synchronizedStatement(Expression lock, Statement body):{visitingExpressions(lock);}
	    case x: \throw(Expression expression):{visitingExpressions(expression);}
	    case x: \try(Statement body, list[Statement] catchClauses):{;}
	    case x: \try(Statement body, list[Statement] catchClauses, Statement \finally)   :{;}                                     
	    case x: \catch(Declaration exception, Statement body):{;}
	    case x: \declarationStatement(Declaration declaration):{;}
	    case x: \while(Expression condition, Statement body):{visitingExpressions(condition);}
	    case x: \expressionStatement(Expression stmt):{visitingExpressions(stmt);}
	    case x: \constructorCall(bool isSuper, Expression expr, list[Expression] arguments):{visitingExpressions(expr); for(a <- arguments){visitingExpressions(a);}}
	    case x: \constructorCall(bool isSuper, list[Expression] arguments):{for(a <- arguments){visitingExpressions(a);}}
    }
}

public int visitingExpressions(Expression exp)
{
	visit(exp){ 
	  case \arrayAccess(Expression array, Expression index):{;}
	  case \newArray(Type \type, list[Expression] dimensions, Expression init):{;}
	  case \newArray(Type \type, list[Expression] dimensions):{;}
	  case \arrayInitializer(list[Expression] elements):{;}
	  case \assignment(Expression lhs, str operator, Expression rhs):{;}
	  case \cast(Type \type, Expression expression):{;}
	  case \characterLiteral(str charValue):{;}
	  case x: \newObject(Expression expr, Type \type, list[Expression] args, Declaration class):{/*println("hit on newObject1 <x@src>"); iprint(class)*/;}
	  case \newObject(Expression expr, Type \type, list[Expression] args):{;}
	  case x: \newObject(Type \type, list[Expression] args, Declaration class):{/*println("hit on newObject2 <x@src>"); iprint(class)*/;}
	  case \newObject(Type \type, list[Expression] args):{;}
	  case \qualifiedName(Expression qualifier, Expression expression):{;}
	  case \conditional(Expression expression, Expression thenBranch, Expression elseBranch):{;}
	  case \fieldAccess(bool isSuper, Expression expression, str name):{;}
	  case \fieldAccess(bool isSuper, str name):{;}
	  case \instanceof(Expression leftSide, Type rightSide):{;}
	  case \methodCall(bool isSuper, str name, list[Expression] arguments):{;}
	  case \methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments):{;}
	  case \null():{;}
	  case \number(str numberValue):{;}
	  case \booleanLiteral(bool boolValue):{;}
	  case \stringLiteral(str stringValue):{;}
	  case \type(Type \type):{;}
	  case \variable(str name, int extraDimensions):{;}
	  case \variable(str name, int extraDimensions, Expression \initializer):{;}
	  case \bracket(Expression expression):{;}
	  case \this():{;}
	  case \this(Expression thisExpression):{;}
	  case \super():{;}
	  case x: \declarationExpression(Declaration decl):{/*println("hit on declarationExpression <x@src>"); iprint(decl)*/;}
	  case \infix(Expression lhs, str operator, Expression rhs):{;}
	  case \postfix(Expression operand, str operator):{;}
	  case \prefix(str operator, Expression operand):{;}
	  case \simpleName(str name):{;}
	  case \markerAnnotation(str typeName):{;}
	  case \normalAnnotation(str typeName, list[Expression] memberValuePairs):{;}
	  case \memberValuePair(str name, Expression \value):{;}
	  case \singleMemberAnnotation(str typeName, Expression \value):{;}
    }
    return 1;
}

public void testCloneDetection()
{
	M3 model = createM3FromEclipseProject(|project://hsqldb|);
	//M3 model = createM3FromEclipseProject(|project://smallsql|);
	println("computed M3, starting cloneDetection Method");
	map[str, set[Declaration]] result = bucketSortDecl(model, threshold);	
	
	//Debug, shor results
	map[Declaration, list[loc]] groups = groupClones(result);
	iprint(groups);
	
	/*
	for(x <- result)
	{
		int i = 0;
		println("Tree type: <x>");
		for(y <- result[x])
		{
			if(i < 10)
			{
				try{
					println("location <i>: <y@src>");
					i += 1;	
				}
				catch NoSuchAnnotation(l) : {
						;
				}
			}
			else 
			  break;
		 }
	}	*/
}

