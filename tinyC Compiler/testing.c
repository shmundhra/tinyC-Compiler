int printi(int num);
int prints(char * c);
int readi(int *eP);


int main()
{
        prints("Doing something random.Enter  2 numbers");
    int a,b,c,d,e;
    int *q=&e;
    int *r=&d;
    a=readi(&a);
    b=readi(&b);
    int i;
    c=a*b;
    prints("initial c\n");
    
    printi(c);
    prints("\n");
    for(i=1;i<10;i++)
    {
        prints("printing");
        c+= b;
        printi(c);
    }
    
    return 0;
}