module CloneDetection

import Prelude;
import String;

//Java Parsing libraries
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;

int threshold = 6;
//set[Declaration]

public void getAST()
{
 	M3 model = createM3FromEclipseProject(|project://testproject|);
	decls = createAstsFromEclipseProject(model.id, false);
	
	/* This also creates a stackoverflow but does work on smaller programs. Unfortanatlly createAstsFromEclipseProject does the same thing. It could be used to split the project.
	
	set[Declaration] decls = {};
		for(file <-files(model))
	{
		createAstFromFile(file, true); //this was a test to see if this was faster. i can't measure the difference yet. DO NOT RUN THIS USING IPRINT UNLESS YOU WANT TO BUY A NEW MACHINE!!!		
	}
	iprint(decls);*/
	
	visit(decls)
	{
		case m : \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): {println("name : <m@src> size of tree is: <sizeOfTree(impl)>"); iprint(impl);}
		
	}
	
	println("m3 files size is: <size(files(model))>");	
	println("ast size is: <size(decls)>");
}

public void testCloneDetection()
{
	M3 model = createM3FromEclipseProject(|project://hsqldb|);
	//M3 model = createM3FromEclipseProject(|project://smallsql|);
	println("computed M3, starting cloneDetection Method");
	map[str, set[Declaration]] result = bucketSortDecl(model, threshold);	
	
	//Debug, shor results
	map[str, list[Declaration]] groups = groupClones(result);
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

public map[str, list[Declaration]] groupClones(map[str, set[Declaration]] buckets)
{
	map[str, list[Declaration]] clones = ();
	
	for(str k <- buckets) // foreach bucket
	{
		int i = 0; //id
		for(Declaration x <- buckets[k]) //foreach declaration in the bucket
		{				
			list[Declaration] clonesfromX = [y | y <- buckets[k],x := y];
			
			if(size(clonesfromX) > 0)
			{
				println(k);
				clones += ( "<k><i>" : clonesfromX );
				i += 1;
			}
		}		
	}	
	
	return clones;
}

public map[str, set[Declaration]] bucketSortDecl(M3 model, int threshold) {

	set[Declaration] decls = createAstsFromEclipseProject(model.id, false);
	println("AST made, bucket sorting decls...");

	set[Declaration] emptyBucket = {};
	
	//buckets
	map[str, set[Declaration]] buckets = (
		//"compilationUnit" : {},
		//"compilationUnitInPackage" : {},
		//"enum" : {},
		//"enumConstant" : {},
		//"enumConstantClass" : {},
		//"class" : {},
		//"anonClass" : {},
		//"interface" : {},
		//"field" : {},
		//"initializer" : {},
		"method" : {}
		//"constructor" : {},
		//"annotationType" : {}
		
		//"emptyMethod" : {},
		//"imports" : {},
		//"package" : {},
		//"parentPackage" : {},
		//"variables" : {},			//special, locations per variable, multiple variable on one line: int a,b,c,d;
		//"typeParameter" : {},
		//"annotationTypeMember" : {},
		//"annotationTypeMemberDefault" : {},
		//"parameter" : {},
		//"vararg" : {}
	);
		
	//hash all subtrees to buckets
	//todo: check if nodemass is big enough 
		visit(decls){		
	    //case x : \compilationUnit(imports, types) : 				 
	    //	{ sizeOfDeclaration(x) >= threshold )buckets["compilationUnit"] += {x}; } 
        //case x : \compilationUnit(package, y, types) : 				 
	    //	{ sizeOfDeclaration(x) >= threshold )buckets["compilationUnitInPackage"] += {x}; }    
        //case x : \enum(name, implements, constants, body)  : 		 
	    //	 { sizeOfDeclaration(x) >= threshold )buckets["enum"] += {x}; }
        //case x : \enumConstant(name, arguments, class) : 
	    //	 { sizeOfDeclaration(x) >= threshold )buckets["enumConstant"] += {x}; }
        //case x : \enumConstant(name, arguments)  : 
		//	 { sizeOfDeclaration(x) >= threshold )buckets["enumConstantClass"] += {x}; }
        //case x : \class(name, extends, implements, body)  : 
		//	 { sizeOfDeclaration(x) >= threshold )buckets["class"] += {x}; }
        //case x : \class(body)  : 
		//	 { sizeOfDeclaration(x) >= threshold )buckets["anonClass"] += {x}; }
        //case x : \interface(name, extends, implements, body)  : 
		//	 { sizeOfDeclaration(x) >= threshold )buckets["interface"] += {x}; }
        //case x : \field(\type, fragments)  : 
		//	 { sizeOfDeclaration(x) >= threshold )buckets["field"] += {x}; }
        case x : \method(\return, name, parameters, exceptions, impl) : 
	    	 { if(sizeOfDeclaration(x) >= threshold ) buckets["method"] += {x}; }
        //case x : \constructor(name, parameters, exceptions, impl)  : 
	    //	 { sizeOfDeclaration(x) >= threshold )buckets["constructor"] += {x}; }
        //case x : \annotationType(name, body)  : 
        //     { sizeOfDeclaration(x) >= threshold )buckets["annotationType"] += {x}; }
        
        
        // case x : \initializer(initializerBody)  : 
	    //	 { sizeOfDeclaration(x) >= threshold )buckets["initializer"] += {x}; }
        //case x : \method(\return, name, parameters, exceptions)  : 
	    //	 { sizeOfDeclaration(x) >= threshold )buckets["emptyMethod"] += {x}; }
        // case x : \import(name)  : 
   		//	 { sizeOfDeclaration(x) >= threshold )buckets["imports"] += {x}; }
        //case x : \package(name)  : 
        //     { sizeOfDeclaration(x) >= threshold )buckets["package"] += {x}; }
        //case x : \package(parentPackage, name)  : 
        //     { sizeOfDeclaration(x) >= threshold )buckets["parentPackage"] += {x}; }
        // case x : \variables(\type, \fragments) : 
        //     { sizeOfDeclaration(x) >= threshold )buckets["variables"] += {x}; }
        // case x : \typeParameter(name, extendsList)  : 
        //     { sizeOfDeclaration(x) >= threshold )buckets["typeParameter"] += {x}; }
        //case x : \annotationTypeMember(\type, name)  : 
        //     { sizeOfDeclaration(x) >= threshold )buckets["annotationTypeMember"] += {x}; }
        //case x : \annotationTypeMember(\type, name, defaultBlock)  : 
        //     { sizeOfDeclaration(x) >= threshold )buckets["annotationTypeMemberDefault"] += {x}; }
        //case x : \parameter(\type, name, extraDimensions)  : 
        //     { sizeOfDeclaration(x) >= threshold )buckets["parameter"] += {x}; }
        //case x : \vararg(\type, name)  : 
        //     { sizeOfDeclaration(x) >= threshold )buckets["vararg"] += {x}; }
	}    		
	
	return buckets;
}

public int sizeOfDeclaration(Declaration decl)
{	
	cnt = 0;
	visit(decl){
		case i: \initializer(Statement initializerBody):{cnt += sizeOfTree(initializerBody);}
		case m: \method(_, _, _, _, Statement impl):{cnt += sizeOfTree(impl); }	
		case c: \constructor(_, _, _, Statement impl) :{cnt += sizeOfTree(impl);}
	}
	return cnt;
}
public int sizeOfTree(Statement state)
{	
	int cnt = 0;
	top-down-break visit(state){
	case \assert(_):{cnt += 1;}
    case \assert(_, _):{cnt += 1;}
    case \block(list[Statement] statements):{for(stat <- statements){cnt += sizeOfTree(stat);} cnt += 1;}
    case \break():{cnt += 1;}
    case \break(_):{cnt += 1;}
    case \continue():{cnt += 1;}
    case \continue(_):{cnt += 1;}
    case \do(Statement body, _):{cnt += sizeOfTree(body) + 1;}
    case \empty():{cnt += 1;}
    case \foreach(_, _, Statement body):{cnt += sizeOfTree(body) + 1;}
    case \for(_, _, _, Statement body):{cnt += sizeOfTree(body) + 1;}
    case \for(_, _, Statement body):{cnt += sizeOfTree(body) + 1;}
    case \if(_, Statement thenBranch):{cnt += sizeOfTree(thenBranch) + 1;}
    case \if(_, Statement thenBranch, Statement elseBranch):{cnt += sizeOfTree(elseBranch) + sizeOfTree(thenBranch) + 1;}
    case \label(_, Statement body):{cnt += sizeOfTree(body) + 1;}
    case \return(_):{cnt += 1;}
    case \return():{cnt += 1;}
    case \switch(_, list[Statement] statements):{for(stat <- statements){cnt += sizeOfTree(stat);} cnt += 1;}
    case \case(_):{cnt += 1;}
    case \defaultCase():{cnt += 1;}
    case \synchronizedStatement(_, Statement body):{cnt+= sizeOfTree(body)+1;}
    case \throw(_):{cnt += 1;}
    case \try(Statement body, list[Statement] catchClauses):{for(stat <- catchClauses){cnt += sizeOfTree(stat);} cnt+= sizeOfTree(body) + 1;}
    case \try(Statement body, list[Statement] catchClauses, Statement \finally):{for(stat <- catchClauses){cnt += sizeOfTree(stat);} cnt+= sizeOfTree(body) + 1;}                                        
    case \catch(_, Statement body):{cnt += sizeOfTree(body) + 1;}
    case \declarationStatement(_):{cnt += 1;}
    case \while(_, Statement body):{cnt += sizeOfTree(body) + 1;}
    case \expressionStatement(_):{cnt += 1;}
    case \constructorCall(_,_,_):{cnt += 1;}
    case \constructorCall(_, _):{cnt += 1;}
    }
    return cnt;
}