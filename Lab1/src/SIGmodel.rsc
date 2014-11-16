module SIGmodel
import Prelude;
import String;
import IO;

//Java Parsing libraries
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

//Utility Libraries
import SIGModelMetrics::Lib::StringCleaning;
import SIGModelMetrics::Lib::CodeCleaning;

//Metric Libraries
import SIGModelMetrics::OveralSize;
import SIGModelMetrics::UnitSize;

public void allMetrics(loc project)
{
	println("Calculating M3 model...");
	model = createM3FromEclipseProject(project);
	println("Done! Calculating Metrics:\r\n");
	
	//Risk due to system size
	overalVolumeMetric(model);
	//Risk due to unit size distribution
	unitSizeMetric(model);
		
}
