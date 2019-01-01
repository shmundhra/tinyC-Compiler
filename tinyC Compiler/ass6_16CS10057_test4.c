int printi(int num);
int prints(char * c);
int readi(int *eP);
/* this program calcualtes the factiorial of a number recursively*/

int fact(int z)
{
	if(z==1)
		return 1;
	else
	{
		return z*fact(z-1);
	}
}

int main()
{
	prints("This program will calcualte the factorial of the number you enter recursively\n");
	int x,c;
	prints("enter a number to calcualte factorial\n");
	z=readi(&c);
	int m;
	m=fact(z);
	prints("factorial of ");
	printi(z);
	prints(" is ");
	printi(m);
	prints("\n");
	return 0;
}