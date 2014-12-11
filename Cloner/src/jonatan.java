
public class jonatan {

	public jonatan makeAJonatan()
	{
		return new jonatan();		
	}
	
	public int foo()
	{
		int a = 0;
		int b = 2;
		
		if(a < b)
		{
			a= b;
			if(b*a == 12)
			{
				return a;
			}
			return b;
		}
		return a+b;
	}
}
