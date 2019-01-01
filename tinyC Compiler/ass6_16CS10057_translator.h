#ifndef ASS5_16CS10057_TRANLATOR_H
#define ASS5_16CS10057_TRANLATOR_H
#include <bits/stdc++.h>
using namespace std;
#define pb push_back
#define size_of_int 4
#define size_of_char 1
#define size_of_double 8
#define size_of_pointer 8

typedef enum
{
	VOID,
	BOOL,
	CHAR,
	INT,
	DOUBLE,
	ARRAY,
	PTR,
	FUNCTION
}Types;

typedef enum 
{
	DEFAULT, ADD, SUB, MULT, DIV, MOD, SL, SR, LT, GT, EQ, NEQ, 
	LTE, GTE, LOG_AND, LOG_OR, BW_AND, BW_OR, BW_XOR, BW_U_NOT ,U_PLUS, U_MINUS, REFERENCE, DEREFERENCE, U_NEG, ASSIGN, GOTO_EQ,
	GOTO_NEQ, GOTO_GT, GOTO_GTE, GOTO_LT, GOTO_LTE, IF_GOTO,
	IF_FALSE_GOTO, CtoI, ItoC, DtoI, ItoD, DtoC ,CtoD, RETURN, PARAM, CALL, GOTO, ARR_IDX_ARG, ARR_IDX_RES, FUNC_END, FUNC_BEG, L_DEREF
}opcode;



class sym_tab;
class sym_tab_row;
class sym_value;
class symbol_type;
class expression;
class declaration;
class quads;
class quad_array;


class sym_tab
{

public:
	map<string,sym_tab_row*> symbol_table;
	vector<sym_tab_row*> symbols;
	int offset;
	sym_tab()
	{offset=0;}
	sym_tab_row* lookup(string var,Types t=INT,int PC=0);
	sym_tab_row* look_in_global(string var);
	string gentemp(Types t=INT);
	void print_symtab();
};

class symbol_type
{
public:
	Types type;
	vector<int> dims;
	int pointers;
	Types type2;
};


class sym_tab_row
{
public:
	string name;
	symbol_type type;
	sym_value *init_val;
	int size;
	int offset;
	sym_tab *nested_table;
	sym_tab_row()
	{
		nested_table=NULL;
	}
};

class sym_value
{
public:
	int a;
	char b;
	double c;
	void *p;
	void set_initial_value(int d)
	{
		a=b=c=d;
		p=NULL;
	}
	void set_initial_value(char d)
	{
		a=b=c=d;
		p=NULL;
	}
	void set_initial_value(double d)
	{
		a=b=c=d;
		p=NULL;
	}

};

class param
{
public:
	string name;
	symbol_type type;
};

class quads
{
public:
	string arg1;
	string arg2;
	string res;
	opcode op;
	quads(string,string ,string,opcode);
	void print_quad();
};


class expression
{
public:
	list<int> TL,FL,NL;
	int instr;
	string loc;
	Types type;
	int fold;                                                   // used to determine the dimention of array being parsed
    string *folder;
    expression()
    {
        fold = 0;
        folder=NULL;
    }
      
};
class quad_array
{
	public:
	vector<quads> list_of_quads;
	int next_inst;
	quad_array(){next_inst=0;}
	void emit(string result,string arg_1,string arg_2,opcode op);
	void backpatch(list<int> dang,int idx);
	void emit(string res,int constant,opcode U_op);
	void emit(string res,double constant,opcode U_op);
	void emit(string res,char constant,opcode U_op);
	void convtotype(string t,Types to,string f,Types form);
	void convtotype(expression *arg,expression *res,Types type);
	void convInttoBool(expression *res);
};

class declarations
{
public:
	string name;
	int pointers;
	vector<int> list;
	expression *init_val;
	int pc;
	Types type;
	Types type2;
};



list<int> makelist(int idx);
list<int> merge(list<int> a,list<int> b);
void gencode();
#endif /*ASS5_16CS10057_TRANLATOR_H */