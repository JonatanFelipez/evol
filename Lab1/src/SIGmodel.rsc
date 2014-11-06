module SIGmodel
import Prelude;
import String;
import lang::java::jdt::m3::Core;

loc project;
M3 model;

public void main()
{
		project = |project://smallsql0.21_src|;}
		model = createM3FromEclipseProject(project);		
}