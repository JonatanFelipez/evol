module CloneDetection

import Prelude;
import Map;
import String;

//Java Parsing libraries
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;

int threshold = 6;
//set[Declaration]

//aliases
alias Sequences = list[Sequence];
alias Sequence = list[Statement];

public void getAST()
{
 	M3 model = createM3FromEclipseProject(|project://testproject|);
	decls = createAstsFromEclipseProject(model.id, false);
	
	/* This also creates a stackoverflow but does work on smaller programs. Unfortunately createAstsFromEclipseProject does the same thing. It could be used to split the project.
	
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

//input: a list of statements, output a list of statement sequences that 
public list[list[Statement]] getStatementSequences(list[Statement] stmts, int threshold)
{
	if(size(stmts) == 0) return [];
	
	list[list[Statement]] sequences = [];
	
	for(int begin <- [0..size(stmts)])
	{
		int end = begin;
		int mass = 0;
		list[Statement] sequence = [];
		
		while(end < size(stmts))
		{
			sequence += stmts[end];
			mass += sizeOfTree(stmts[end]);
			end += 1;
			
			if(mass >= threshold)
				sequences += [sequence];
		}		
	}
	return sequences;	
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

//change declaration to boom
public map[Declaration, list[loc]] groupClones(map[str, set[Declaration]] buckets)
{
	//clone classes
	map[Declaration, list[loc]] cloneClasses = ();
	
	for(str k <- buckets) // foreach bucket
	{
		for(Declaration x <- buckets[k]) //foreach declaration in the bucket
		{			
			if(x in cloneClasses)
			{
				/////////////////////////////// Test
				locs = cloneClasses[x];
				if(x@src notin locs)
					cloneClasses[x] += ( x@src ); 
				///////////////////////////////
			}
			else
				cloneClasses += ( x : [x@src]);
		}		
	}	
	
	return cloneClasses;
}

public map[Sequence, list[loc]] getClones(set[Declaration] AST, int threshold)
{
	println("Finding Clones......");
	
	println("Get decClones...."); 
	map[Declaration, list[loc]] decClones = getBucketsDec(AST, threshold);
	println("Get seqClones......");
	map[Sequence, list[loc]] seqClones = getBucketsSeq(AST, threshold);
	map[loc, list[loc]] par2Child = ();
	map[loc, list[loc]] cloneClasses = ();
	
	list[loc] seqLocs = [];
	
	println("Looking for childeren");
	for(parClones <- seqClones)
		for(loc par <- seqClones[parClones])
			seqLocs += [par];	
	
	for(seq <- seqLocs){				
		//par2Child += (par : childs | <par, childs> <- findChildren(seq, seqs));
		x = findChildren(seq, seqLocs);
		 par2Child += (x[0] : x[1]);
	}
	
	println("get loc2Seq.....");	
	map[loc, Sequence] loc2Seq = ();
	for(seq <- seqClones)
		for(location <- seqClones[seq])			
				loc2Seq[location] = seq;
	
	println("get child2Par.....");
	map[loc, loc] child2Par = ();
	for(par <- par2Child)
		for(child <- par2Child[par])			
				child2Par[child] = par;
	
	for(parent <- par2Child)
	{
		if(size(par2Child[parent]) > 0)
		{
			println(parent);
		}
	}
	
	list[loc] children = [x | x <- child2Par];
	for(child <-children)
	{		
		sequence = loc2Seq[child];
		println("sequence: <sequence>");
		println("child: <child>");
		clones = [x | x <- seqClones[sequence], x != child];
		par = child2Par[child];
		parSeq = loc2Seq[par];
		
		parClones = [x|x<-seqClones[parSeq], x != par];
		bool subClass = true;
		
		for(cc <- clones)
		{
			hasParent = false;
			for(pc <- parClones)
				if(containsIn(pc,cc))
				{
					hasParent = true;
					break;
				}
			if(!hasParent)
			{
				subClass = false;
				break;	
			}		
		}
		
		if(subClass)
			{seqClones = seqClones & (sequence : seqClones[sequence]); break;}
	}
	
	return seqClones;
		/*
	for(par <- par2Child){
		for(childs <- par2Child[par])
		{
			for(child <- childs)
			{
				for(seqs <- seqClones)
				{
					for(seq <- seqClones[seqs])
					{
						for(seqLoc <- seq)
						{
							if(child == seqLoc)
							{
								if()

							}
						}
					}
				}
			}
		}
		
	}*/
	//build up par2Child
	// par2Child = (par : childs | <par,childs> <- findChildren(parent, children);
	//par2Child = (par : childs | <par, childs> <- findChildren(parent, children));	
	
	//Now the difficult part:
	// - for all sequence clones:
	// 		filter sequence clone x 
	//			if x has a parent 
	//			AND all clones of x have a parent that is a clone of the parent of x
	//	
	// After this is done, you have all the clone classes. 
	// Convert this to JSON so that it can be used as input for visualization: www.highcharts.com
	
	// eerst alles met een parent vinden.
	// dan kijken of die een klonen heeft.
	//zo ja kijken of al die klonen in een kloon van de parent zitten.
}

public tuple[loc, list[loc]] findChildren(loc parent, list[loc] childeren)
{	
	list[loc] locPar2Child = [];
		
	for(child <- childeren, parent != child && containsIn(parent, child))
		locPar2Child += [child];			
	
	return <parent, locPar2Child>;
}

public map[Declaration, list[loc]] getBucketsDec(set[Declaration] AST, int threshold)
{	
	map[Declaration, list[loc]] dec2Loc = ();
	visit(AST){
		case Declaration x: {
				newDec2Loc = groupClones(bucketSortDecl(x, threshold));
				for(dec <- newDec2Loc)
				{
					if(dec in dec2Loc)
					{
						for(newLocation <- newDec2Loc[dec])
						{
							if(newLocation notin dec2Loc[dec])
							{
								dec2Loc[dec] += [newLocation];
							}
						}						
					}else{
						dec2Loc += (dec : newDec2Loc[dec]);
					}
				}
			}
	}		
	return (seq : dec2Loc[seq] | seq <- dec2Loc, size(dec2Loc[seq])>1);
	//return dec2Loc;
} 

public map[Sequence, list[loc]] getBucketsSeq(set[Declaration] AST, int threshold)
{	
	map[Sequence, list[loc]] seq2Loc = ();
	visit(AST){
		case i: \initializer(Statement initializerBody):{
			newSeq2Loc = bucketSortSequence(initializerBody, threshold);
			
			for(seqs <- newSeq2Loc)
			{				
				if(seqs in seq2Loc){
					seq2Loc[seqs] += newSeq2Loc[seqs];
				}else{
					seq2Loc += (seqs : newSeq2Loc[seqs]);
				}								
			}					
		}
		case m: \method(_, _, _, _, Statement impl):{
			newSeq2Loc = bucketSortSequence(impl, threshold);
			
			for(seqs <- newSeq2Loc)
			{				
				if(seqs in seq2Loc){
					seq2Loc[seqs] += newSeq2Loc[seqs];
				}else{
					seq2Loc += (seqs : newSeq2Loc[seqs]);
				}								
			}			
		}	
		case c: \constructor(_, _, _, Statement impl) :{
			newSeq2Loc = bucketSortSequence(impl, threshold);
			
			for(seqs <- newSeq2Loc)
			{				
				if(seqs in seq2Loc){
					seq2Loc[seqs] += newSeq2Loc[seqs];
				}else{
					seq2Loc += (seqs : newSeq2Loc[seqs]);
				}								
			}			
		}
	}
	return (seq : seq2Loc[seq] | seq <- seq2Loc, size(seq2Loc[seq])>1);
	//return seq2Loc;
}

public map[Sequence, list[loc]] bucketSortSequence(Statement state, int threshold)
{
	list[Sequences] sequences = ripStatement(state, threshold);
	map[Sequence, list[loc]] buckets = ();	
	
	for(seqs <- sequences)
	{		
		for(seq <- seqs)
		{	
			if(seq in buckets){
				//allready in the bucket
				buckets[seq] += [addLocs(seq[0]@src, seq[size(seq)-1]@src)];
			}else{		
				//not in the bucket						
				buckets += (seq : [addLocs(seq[0]@src, seq[size(seq)-1]@src)]);
			}										
		}
	}
	return buckets;
}

public map[Statement, list[loc]] bucketSortStat(Statement stat, int threshold)
{
	map[Statement, list[loc]] buckets = ();
	
	visit(stat)
	{
		case Statement x: {
			if(x in buckets){					
					buckets[x] += [x@src];					 
				}
			else if(sizeOfTree(x) >= threshold)
			 		buckets += (x : [x@src]);}
	}	
	return buckets;
}

//change declaration to boom
public map[str, set[Declaration]] bucketSortDecl(Declaration dec, int threshold) {
	
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
		"constructor" : {},
		"annotationType" : {}
	);
		
	//hash all subtrees to buckets
	visit(dec){		
	    case x : \compilationUnit(imports, types) : 				 
	    	{ if(sizeOfDeclaration(x) >= threshold) buckets["compilationUnit"] += {x}; } 
        case x : \compilationUnit(package, y, types) : 				 
	    	{ if(sizeOfDeclaration(x) >= threshold )buckets["compilationUnitInPackage"] += {x}; }    
        case x : \enum(name, implements, constants, body)  : 		 
	    	{ if(sizeOfDeclaration(x) >= threshold )buckets["enum"] += {x}; }
        case x : \enumConstant(name, arguments, class) : 
	    	{ if(sizeOfDeclaration(x) >= threshold )buckets["enumConstant"] += {x}; }
        case x : \enumConstant(name, arguments)  : 
			{ if(sizeOfDeclaration(x) >= threshold )buckets["enumConstantClass"] += {x}; }
        case x : \class(name, extends, implements, body)  : 
			{ if(sizeOfDeclaration(x) >= threshold )buckets["class"] += {x}; }
        case x : \class(body)  : 
			{ if(sizeOfDeclaration(x) >= threshold )buckets["anonClass"] += {x}; }
        case x : \interface(name, extends, implements, body)  : 
			{ if(sizeOfDeclaration(x) >= threshold )buckets["interface"] += {x}; }
        case x : \field(\type, fragments)  : 
			{ if(sizeOfDeclaration(x) >= threshold )buckets["field"] += {x}; }
        case x : \method(\return, name, parameters, exceptions, impl) : 
	    	{ if(sizeOfDeclaration(x) >= threshold ) buckets["method"] += {x}; }
        case x : \constructor(name, parameters, exceptions, impl)  : 
	    	{ if(sizeOfDeclaration(x) >= threshold )buckets["constructor"] += {x}; }
        case x : \annotationType(name, body)  : 
            { if(sizeOfDeclaration(x) >= threshold )buckets["annotationType"] += {x}; }        
         case x : \initializer(initializerBody)  : 
	    	 { if(sizeOfDeclaration(x) >= threshold )buckets["initializer"] += {x}; }
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

//Using relation instead of list
public list[list[list[Statement]]] ripStatement(Statement state, int threshold)
{	
	list[list[list[Statement]]] sequences = [];
	
	visit(state){
		case x : \block(list[Statement] statements):{sequences += [getStatementSequences(statements, threshold)];} //need this		
    }
    return sequences;    
}

private bool containsIn(loc parent, loc child)
{
	return parent.uri == child.uri && 
		   child.begin.line >= parent.begin.line &&
		   child.end.line <= parent.end.line;	
}

loc addLocs(loc s, loc r) {
    res = s;
    res.end = r.end;
    adjust = 0;
    if (s.offset + s.length < r.offset) {
        adjust = r.offset - (s.offset+s.length);
    }
    res.length = s.length + r.length + adjust;
    return res;
}