/**
    Vikas Choudhary
    13CS30038
*/
int printi(int x);
int prints(char *x);
int readi(int *x);

int func(int x)
{
    int z;
    z=x+1;
    return z;
}

int main()
{
    int x;
    x=10;
    int a[5];
    a[1]=func(x);
    printi(a[1]);
    return 0;
}