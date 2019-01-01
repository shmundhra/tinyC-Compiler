int printi(int num);
int prints(char * c);
int readi(int *eP);

/*this program checks for taking input output printing and some arithmetic operations*/
int m=10;

int swap(int *m,int *n)
{
    int temp;
    temp=*m;
    *m=*n;
    *n=temp;
    return 0;
}
int main()
{
    int x,c;
    prints("Enter a value\n");
    x=readi(&c);        //reading in x;
    prints("The value you entered was ");
    printi(x);
    prints("\n");   //printing x;

    int a[10],i;
    // reading a array
    prints("Enter 10 values of array\n");
    for(i=0;i<10;i++)
    {
        a[i]=readi(&c);     // reading a[i]
    }
    printi(a[5]);
    prints("\n");
    prints("Printing 10 values of array you entered\n");
    for(i=0;i<10;i++)
    {
        printi(a[i]);
        prints(" ");
    }
    prints("\n\n");

    //finding the min in the array
    int min=a[0];
    for(i=1;i<10;i++)
    {
        if(min > a[i])
        {
            min=a[i];
        }
    }
    prints("Minimum in the array is ");
    printi(min);
    prints("\n\n");
    prints("global varaible m post incremented\n");
    int zz=m++;
    prints("doing zz=m++ zz = ");
    printi(zz);
    prints("  m = ");
    printi(m);
    prints("\n\n");

    prints("Using pointers and swapping two numbers by passing there pointer to a function\nEnter value one\n");
    int x,y,c;
    x=readi(&c);
    prints("Enter value two\n");
    y=readi(&c);
    prints("Initial values\nx=");
    printi(x);
    prints("\ny=");
    printi(y);
    prints("\n");
    prints("Swapped values after passing there pointer to swap function\n");
    int *m;
    int *n;
    m=&x;
    n=&y;
    swap(m,n);
    prints("x=");
    printi(x);
    prints("\ny=");
    printi(y);
    prints("\n");
    return 0;
}