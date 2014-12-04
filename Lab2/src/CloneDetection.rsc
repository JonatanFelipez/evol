module CloneDetection

import Prelude;
import String;

//Java Parsing libraries
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;

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

list[Expression] ripListExpression(list[Expression] exp)
{
	return |x|x<-exp|ripExpression(x)|;
}

Expression ripExpression(Expression exp)
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