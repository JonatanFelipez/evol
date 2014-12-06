module CloneDetection

import Prelude;
import String;

//Java Parsing libraries
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;

public void testCloneDetection()
{
	//M3 model = createM3FromEclipseProject(|project://testproject/src/Testcase.java|);
	M3 model = createM3FromEclipseProject(|project://smallsql|);
	println("computed M3, starting cloneDetection Method");
	map[str, set[Declaration]] result = cloneDetection(model, 50);
	
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
				catch NoSuchAnnotation(l) : 
					{
						;//println("no annotation src for <x>");
						//iprint(result[x]);
					}
			}
			else 
			  break;
		 }
	}	
}

public map[str, set[Declaration]] cloneDetection(M3 model, int threshold) {

	set[Declaration] decls = createAstsFromEclipseProject(model.id, true);
	println("AST made");
	//iprint(decls);

	set[Declaration] emptyBucket = {};
	
	//buckets
	map[str, set[Declaration]] buckets = (
		"compilationUnit" : {},
		"compilationUnitInPackage" : {},
		"enum" : {},
		"enumConstant" : {},
		"enumConstantClass" : {},
		"class" : {},
		"anonClass" : {},
		"interface" : {},
		"field" : {},
		"initializer" : {},
		"method" : {},
		"emptyMethod" : {},
		"constructor" : {},
		"imports" : {},
		//"package" : {},
		//"parentPackage" : {},
		"variables" : {},			//special, locations per variable, multiple variable on one line: int a,b,c,d;
		"typeParameter" : {},
		"annotationType" : {},
		"annotationTypeMember" : {},
		"annotationTypeMemberDefault" : {},
		"parameter" : {},
		"vararg" : {}
	);
		
	//hash all subtrees to buckets
	//todo: check if nodemass is big enough 
		visit(decls){		
	    case x : \compilationUnit(imports, types) : 				 
	    	{ buckets["compilationUnit"] += {x}; } 
        case x : \compilationUnit(package, y, types) : 				 
	    	{ buckets["compilationUnitInPackage"] += {x}; }    
        case x : \enum(name, implements, constants, body)  : 		 
	    	 { buckets["enum"] += {x}; }
        case x : \enumConstant(name, arguments, class) : 
	    	 { buckets["enumConstant"] += {x}; }
        case x : \enumConstant(name, arguments)  : 
			 { buckets["enumConstantClass"] += {x}; }
        case x : \class(name, extends, implements, body)  : 
			 { buckets["class"] += {x}; }
        case x : \class(body)  : 
			 { buckets["anonClass"] += {x}; }
        case x : \interface(name, extends, implements, body)  : 
			 { buckets["interface"] += {x}; }
        case x : \field(\type, fragments)  : 
			 { buckets["field"] += {x}; }
        case x : \initializer(initializerBody)  : 
	    	 { buckets["initializer"] += {x}; }
        case x : \method(\return, name, parameters, exceptions, impl) : 
	    	 { buckets["method"] += {x}; }
        case x : \method(\return, name, parameters, exceptions)  : 
	    	 { buckets["emptyMethod"] += {x}; }
        case x : \constructor(name, parameters, exceptions, impl)  : 
	    	 { buckets["constructor"] += {x}; }
        case x : \import(name)  : 
   			 { buckets["imports"] += {x}; }
        //case x : \package(name)  : 
        //     { buckets["package"] += {x}; }
        //case x : \package(parentPackage, name)  : 
        //     { buckets["parentPackage"] += {x}; }
        case x : \variables(\type, \fragments) : 
             { buckets["variables"] += {x}; }
        case x : \typeParameter(name, extendsList)  : 
             { buckets["typeParameter"] += {x}; }
        case x : \annotationType(name, body)  : 
             { buckets["annotationType"] += {x}; }
        case x : \annotationTypeMember(\type, name)  : 
             { buckets["annotationTypeMember"] += {x}; }
        case x : \annotationTypeMember(\type, name, defaultBlock)  : 
             { buckets["annotationTypeMemberDefault"] += {x}; }
        case x : \parameter(\type, name, extraDimensions)  : 
             { buckets["parameter"] += {x}; }
        case x : \vararg(\type, name)  : 
             { buckets["vararg"] += {x}; }
	}    		
	
	return buckets;
}

public set[Declaration] cloneDetection(M3 model, int threshold){

	set[Declaration] decls = createAstsFromEclipseProject(model.id, true); //need a tree to look for statements and declarations
	//map[str, tuple[int, set[loc]]] clones; //key is methodname, int is the number of occurrens, set[loc] locations of the clone 
	map[Declaration, tuple[map[str,str] attributes, set[Declaration] clones]] clones;
	
	return visit(decls){		
			    case \compilationUnit(_, types) => \compilationUnit([], types)
    		    case \compilationUnit(_, _, types) => \compilationUint([], types)
			    case \enum(str name, list[Type] implements, list[Declaration] constants, list[Declaration] body) => \enum("", implements, constants, body)
			    case \enumConstant(str name, list[Expression] arguments, Declaration class) => \enumConstant("", arguments, class)    
			    case \enumConstant(str name, list[Expression] arguments) => \enumConstant("", arguments)
			    case \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body) => \class("", extends, implements, body)
			    case \class(list[Declaration] body) => \class(body)
			    case \interface(str name, list[Type] extends, list[Type] implements, list[Declaration] body) => \interface("", extends, implements, body)
			    case \field(Type \type, list[Expression] fragments) => \field(\type,  fragments)
			    case \initializer(Statement initializerBody) => \initializer(initializerBody)
			    case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) =>\method(\return, "", parameters, exceptions, impl)
			    case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions) => \method(\return, "",  parameters, exceptions)
			    case \constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) => \constructor("", parameters, exceptions, impl)
		   		case \import(str name) => \import("")
			    case \package(str name) => \package("")
			    case \package(Declaration parentPackage, str name) => \package(parentPackage, "")
			    case \variables(Type \type, list[Expression] \fragments) => \variables(\type, \fragments)
			    case \typeParameter(str name, list[Type] extendsList) => \typeParameter(_, extendsList)
			    case \annotationType(str name, list[Declaration] body) => \annotationType(_, body)
			    case \annotationTypeMember(Type \type, str name) => \annotationTypeMember(\type, "")
			    case \annotationTypeMember(Type \type, str name, Expression defaultBlock) => \annotationTypeMember(\type, _, defaultBlock)    
			    case \parameter(Type \type, str name, int extraDimensions) => \parameter(\type, "", extraDimensions)
			    case \vararg(Type \type, str name) => \vararg(\type, "")
				}
		
	return decls;				 				
}

Statement ripStatements(Statement state)
{
	return visit(state){
	case \assert(Expression expression):{;}
    case \assert(Expression expression, Expression message):{;}
    case \block(list[Statement] statements):{;}
    case \break():{;}
    case \break(str label):{;}
    case \continue():{;}
    case \continue(str label):{;}
    case \do(Statement body, Expression condition):{;}
    case \empty():{;}
    case \foreach(Declaration parameter, Expression collection, Statement body):{;}
    case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body):{;}
    case \for(list[Expression] initializers, list[Expression] updaters, Statement body):{;}
    case \if(Expression condition, Statement thenBranch):{;}
    case \if(Expression condition, Statement thenBranch, Statement elseBranch):{;}
    case \label(str name, Statement body):{;}
    case \return(Expression expression):{;}
    case \return():{;}
    case \switch(Expression expression, list[Statement] statements):{;}
    case \case(Expression expression):{;}
    case \defaultCase():{;}
    case \synchronizedStatement(Expression lock, Statement body):{;}
    case \throw(Expression expression):{;}
    case \try(Statement body, list[Statement] catchClauses):{;}
    case \try(Statement body, list[Statement] catchClauses, Statement \finally):{;}                                        
    case \catch(Declaration exception, Statement body):{;}
    case \declarationStatement(Declaration declaration):{;}
    case \while(Expression condition, Statement body):{;}
    case \expressionStatement(Expression stmt):{;}
    case \constructorCall(bool isSuper, Expression expr, list[Expression] arguments):{;}
    case \constructorCall(bool isSuper, list[Expression] arguments):{;}
	}
}
/*
list[Expression] ripListExpression(list[Expression] exp)
{
}

public Expression ripExpression(Expression exp)
{

	return visit(exp){
	case \arrayAccess(Expression array, Expression index) => \arrayAccess(ripExpression(array), ripExpression(index))
    case \newArray(Type \type, list[Expression] dimensions, Expression init) => \newArray(\type, dimensions, ripExpression(init))
    case \newArray(Type \type, list[Expression] dimensions) => \newArray(\type, dimensions)
    case \arrayInitializer(list[Expression] elements) => \arrayInitializer(elements)
    case \assignment(Expression lhs, str operator, Expression rhs) \assignment(Expression lhs, str operator, Expression rhs)
    case \cast(Type \type, Expression expression)
    case \characterLiteral(str charValue)
    case \newObject(Expression expr, Type \type, list[Expression] args, Declaration class)
    case \newObject(Expression expr, Type \type, list[Expression] args)
    case \newObject(Type \type, list[Expression] args, Declaration class)
    case \newObject(Type \type, list[Expression] args)
    case \qualifiedName(Expression qualifier, Expression expression)
    case \conditional(Expression expression, Expression thenBranch, Expression elseBranch)
    case \fieldAccess(bool isSuper, Expression expression, str name)
    case \fieldAccess(bool isSuper, str name)
    case \instanceof(Expression leftSide, Type rightSide)
    case \methodCall(bool isSuper, str name, list[Expression] arguments)
    case \methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments)
    case \null()
    case \number(str numberValue)
    case \booleanLiteral(bool boolValue)
    case \stringLiteral(str stringValue)
    case \type(Type \type)
    case \variable(str name, int extraDimensions)
    case \variable(str name, int extraDimensions, Expression \initializer)
    case \bracket(Expression expression)
    case \this()
    case \this(Expression thisExpression)
    case \super()
    case \declarationExpression(Declaration decl)
    case \infix(Expression lhs, str operator, Expression rhs)
    case \postfix(Expression operand, str operator)
    case \prefix(str operator, Expression operand)
    case \simpleName(str name)
    case \markerAnnotation(str typeName)
    case \normalAnnotation(str typeName, list[Expression] memberValuePairs)
    case \memberValuePair(str name, Expression \value)             
    case \singleMemberAnnotation(str typeName, Expression \value)
	}

}
*/

int cloneBodyDetection(Statement stat, int limit)
{	
	
	 visit(stat){
	 	//Decision making statements
		case \if(Expression condition, _):  //if
			{;}			
		case \if(Expression condition, _, _): //if-else
			{;}
		case \case(_):  //switch-case
			{;}
		
		//Loop statements
		case \while(Expression condition,_): //while 
			{;}		 
		case \for(_,_,_,_): //normal for
			{;}			 
		case \for(_,_,_): //enhanced for
			{;}
		case \do(_, Expression condition): //do
			{;}	
		
		//Exception statements
		case \try(_,_): //try-catch
			{;}
 		case \try(_,_,_): //try-catch-finally
 			{;}			
	}
}