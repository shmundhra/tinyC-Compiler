#include "myl.h"
#define MAX_LENGTH 100


int prints(char *inp) 			//prints a stirng of characters and returns the number of characters
{
	int no_of_char=0;
	int i=0;
	while(*(inp+i))
	{
		i++;
		no_of_char++;
	}
	__asm__ __volatile__(
			 "movl $1,%%eax \n\t"
			 "movq $1,%%rdi \n\t"
			 "syscall\n\t"
			 :
			 : "S"(inp) , "d"(no_of_char)
		);
	return no_of_char;
}

int printi(int n)
{
	char num[MAX_LENGTH];
	int i=0;
	if(!n)
	{
		num[i++]='0';
	}
	else if(n<0)
	{
		num[i++]='-';
		n=(-1)*n;
	}
	int l=i;
	int temp;
	while(n>0)
	{
		temp=n%10;
		num[i++]=(char)(temp+'0');
		n=n/10;
	}
	int r=i-1;
	char temp2;
	while(l<=r)
	{
		temp2=num[l];
		num[l++]=num[r];
		num[r--]=temp2;
	}
	num[i]='\0';
	__asm__ __volatile__(
			"movl $1 ,%%eax \n\t"
			"movq $1 ,%%rdi \n\t"
			"syscall \n\t"
			:
	 		: "S"(num) , "d"(i)
		);
	return i;
}

int readi(int *ep)
{
	char num[MAX_LENGTH];
	int i=0,l=0,r;
	do
	{
		__asm__ __volatile__(
				"movl $0 ,%%eax \n\t"
				"movq $1 ,%%rdi \n\t"
				"syscall \n\t"
				:
				: "S"(num+i) , "d"(1)
			);
	}while(num[i++]!='\n');
	i--;
	r=i-1;
	if(num[0]=='-')
		l=1;
	int char_to_num=0;
	while(l<=r)
	{
		if(num[l]<'0' || num[l]>'9')
		{
			(*ep)=ERR;
			return *ep;
		}
		char_to_num=char_to_num*10+(int)(num[l++]-'0');
	}
	if(num[0]=='-')
		char_to_num=(-1)*char_to_num;
	(*ep)=OK;
	return char_to_num;
}


