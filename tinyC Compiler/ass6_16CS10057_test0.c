int printi(int num);
int prints(char * c);
int readi(int *eP);



int bsearch(int a[],int l,int r,int x)
{
    
    while(l <= r)
    {
        int mid=(l+r)/2;
        printi(mid);
        prints(" ");
        printi(a[mid]);
        prints("\n");
        if(a[mid]==x)
        {
            return mid;
        }
        else if(a[mid]<x)
        {
            l=mid+1;
        }
        else
        {
            r=mid-1;
        }
    }
    int b=-1;
    return b;
}

int main()
{
    int a[10];
    int i;
    int c;
    for(i=0;i<10;i++)
    {
        prints("enter a number\n");
        a[i]=readi(&c);
        printi(a[i]);
        prints("\n");
    }
    int x,c,v;
    prints("Enter a number on which you want to do binary search\n");
    c=readi(&v);
    x=bsearch(a,0,9,c);
    printi(x);
    prints("\n");
   return 0;
}

