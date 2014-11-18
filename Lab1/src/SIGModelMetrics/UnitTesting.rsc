module SIGModelMetrics::UnitTesting

/*
Total Coverage Percentage
TPC = (BT + BF + SC + MC)/(2*B + S + M) * 100%
 
where
 
BT - branches that evaluated to "true" at least once
BF - branches that evaluated to "false" at least once
SC - statements covered
MC - methods entered
 
B - total number of branches
S - total number of statements
M - total number of methods
*/

/*
	Rank	Coverage
	++		>95%
	+		>80%
	0		>60%
	-		>20%
	--		>0%
*/

//number of executed statements
public void coveredStatements()
{}

//number of executed Methods (is the method really used)
public void enteredMethods()
{}

/*Branch coverage (sometimes called Decision Coverage) measures which possible branches in flow control structures are followed.
 this can be done by recording if the boolean expression in the control structure evaluated to both true and false during execution.*/
public void coveredBranches()
{}

//total number of branches in the system
public void totalBranches()
{}

//total number of statements in the system
public void totalStatements()
{}

//total number of methods in the system
public void totalMethods ()
{}
