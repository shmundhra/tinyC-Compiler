int printi(int num);
int prints(char * c);
int readi(int *eP);
/*sorting an array*/

int pow(int x)
{
	if(x==0)
	{
		return 1;
	}
	else if(x==1)
	{
		return 2;
	}
	else
	{
		int m;
		if(x%2==0)
		{
			m=pow(x/2);
			return m*m;
		}
		else
		{
			m=pow(x/2);
			return m*m*2;
		}
	}
}
int main()
{
	prints("Enter a numbner to calculate 2 power that number\n");
	int x,c;
	x=readi(&c);
	int ans;
	ans=pow(x);
	prints("2 power ");
	printi(x);
	prints(" is ");
	printi(ans);
	prints("\n");
	return 0;
}