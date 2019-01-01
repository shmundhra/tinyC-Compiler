%{
#include <string>
#include <iostream>

using namespace std;
extern int yylex();
void yyerror(string s);
extern int yydebug;
#include "ass6_16CS10057_translator.h"
quad_array QUAD_LIST;
sym_tab gst;
sym_tab *GST = &(gst);
int counts=0;
vector<string> str_consts;

%}




%union {
  char cval;                      // used for storing the character constant value
    int ival;                       // used for storing the integer constant value
    double dval;                    /// used for storing the double constant value
    void* ptr;                      // used for storing the pointer value
    string *str;                    // pointer to a string
    symbol_type *type_info;              // keeps info of all the types
    sym_tab_row *sym_tab_rowdata;              // a pointer to an entry in the symbol table
    Types typee;              // a basic type enum
    //exp *exp_info;
    opcode opp;                     // for storing the opcode of a nonterminal
    expression *exp_info;                 // holds info like loc and type for an expression and truelist false list and next list for statements
    declarations *dec_info;                 // holds info on declartors
    vector<declarations*> *ivec;            // holds a list od declators
    param *prm;                     // holds parameters like name and type of a parameter
    vector<param*> *prm_list;       // holds a list of parameters
}
%token AUTO_KEY;
%token ENUM_KEY;
%token RESTRICT_KEY;
%token UNSIGNED_KEY;
%token BREAK_KEY;
%token EXTERN_KEY;
%token RETURN_KEY;
%token VOID_KEY;
%token CASE_KEY;
%token FLOAT_KEY;
%token SHORT_KEY;
%token VOLATILE_KEY;
%token CHAR_KEY;
%token FOR_KEY;
%token SIGNED_KEY;
%token WHILE_KEY;
%token CONST_KEY;
%token GOTO_KEY;
%token SIZEOF_KEY;
%token BOOL_KEY;
%token CONTINUE_KEY;
%token IF_KEY;
%token STATIC_KEY;
%token COMPLEX_KEY;
%token DEFAULT_KEY;
%token INLINE_KEY;
%token STRUCT_KEY;
%token IMAGINARY_KEY;
%token DO_KEY;
%token INT_KEY;
%token SWITCH_KEY;
%token DOUBLE_KEY;
%token LONG_KEY;
%token TYPEDEF_KEY;
%token ELSE_KEY;
%token REGISTER_KEY;
%token UNION_KEY;
%token <str> IDENTIFIER;
%token <ival>  INTEGER_CONST;
%token <dval> FLOAT_CONST;
%token <ival> ENUMERATION;
%token <cval> CHAR_CONST;
%token <str> STRING_LITERAL;
%token VAL_AT;
%token PLUS_PLUS;
%token MINUS_MINUS;
%token LEFT_SHIFT;
%token RIGHT_SHIFT;
%token LESS_THAN_EQUAL;
%token GREATER_THAN_EQUAL;
%token EQUAL_EQUAL;
%token NOT_EQUAL;
%token LOGICAL_AND;
%token LOGICAL_OR;
%token ELLIPSES;
%token MULTIPLY_EQUAL;
%token DIVIDE_EQUAL;
%token MODULO_EQUAL;
%token PLUS_EQUAL;
%token MINUS_EQUAL;
%token LEFT_SHIFT_EQUAL;
%token RIGHT_SHIFT_EQUAL;
%token AND_EQUAL;
%token BITWISENOT_EQUAL;
%token OR_EQUAL;


%type<exp_info> primary_expression 
%type<exp_info> expression 
%type<exp_info> postfix_expression assignment_expression unary_expression
%type<exp_info> additive_expression multiplicative_expression shift_expression cast_expression
%type<exp_info> relational_expression equality_expression
%type<exp_info> M N conditional_expression logical_or_expression logical_and_expression and_expression exclusive_or_expression inclusive_or_expression
%type<exp_info> selection_statement statement iteration_statement compound_statement expression_statement jump_statement
%type<cval> unary_operator
%type<exp_info> block_item block_item_list
%type<typee> type_specifier declaration_specifiers
%type<ival> pointer
%type<dec_info> direct_declarator initializer_list declarator init_declarator function_prototype
%type<exp_info> initializer
%type<ivec> init_declarator_list
%type<prm> parameter_declaration
%type<prm_list> parameter_list parameter_type_list argument_expression_list parameter_type_list_opt

%expect 1
%nonassoc ELSE_KEY;

%start translation_unit;
%%




primary_expression
	: IDENTIFIER
	{
	 	$$ = new expression;
	 	string t = (*($1));
	 	////cerr << t << " hkdb\n";
 	 	GST->lookup(t);
	 	$$->loc=t;
	}
	| INTEGER_CONST
	{
		$$ = new expression;
		$$->loc = GST->gentemp(INT);
		QUAD_LIST.emit($$->loc,$1,ASSIGN);
		sym_value *insert=new sym_value; 
		insert->set_initial_value($1);
		GST->lookup($$->loc)->init_val = insert;
	}
	| FLOAT_CONST
	{
		$$ = new expression;
		$$->loc = GST->gentemp(DOUBLE);
		QUAD_LIST.emit($$->loc,$1,ASSIGN);
		sym_value *insert=new sym_value(); /*check_name*/	
		insert->set_initial_value($1);
		GST->lookup($$->loc)->init_val = insert;
	}
	| CHAR_CONST
	{
		$$ = new expression;
		$$->loc = GST->gentemp(CHAR);
		QUAD_LIST.emit($$->loc,$1,ASSIGN);
		sym_value *insert=new sym_value(); /*check_name*/	
		insert->set_initial_value($1);
		GST->lookup($$->loc)->init_val = insert;
	}
	| ENUMERATION
	{}
	| STRING_LITERAL
	{
		$$ = new expression;
		stringstream conv;
		conv << counts;
		counts++;
		string x;
		conv >> x;
		x=".LC"+x;
		$$->loc=x;
		////cerr << "String passed " << *$1 << endl;
		str_consts.pb(*$1);

	}
	| '(' expression ')'
	{ 
		$$ =$2;
	}
	;

postfix_expression
	: primary_expression
	| postfix_expression '[' expression ']'
	{
		//cerr << "array declaration\n";
		symbol_type to = GST->lookup($1->loc)->type;
		string f;
		if(!$1->fold)
		{
			f=GST->gentemp(INT);
			QUAD_LIST.emit(f,0,ASSIGN);
			$1->folder=new string(f);
		}
/*
		f =*($1->folder);
		int mult=to.dims[$1->fold];
		$1->fold++;
		stringstream conv;
		conv << mult;
		string s;
		conv >> s;
		string temp=GST->gentemp(INT);
		QUAD_LIST.emit(temp,$3->loc,"",ASSIGN);
		QUAD_LIST.emit(f,f,s,MULT);
		QUAD_LIST.emit(temp,temp,"4",MULT);
		QUAD_LIST.emit(f,f,temp,ADD);
*/
		string temp2=GST->gentemp(INT);
		QUAD_LIST.emit(temp2,$3->loc,"",ASSIGN);
		QUAD_LIST.emit(temp2,temp2,"4",MULT);
		QUAD_LIST.emit(f,temp2,"",ASSIGN);
		//cerr << $1->loc << "asmvc\n";
		$$=$1;
		//cerr  << "array end\n";
	}
	| postfix_expression '(' ')'
	{
		sym_tab *func_symtab=gst.lookup($1->loc)->nested_table;
		QUAD_LIST.emit($1->loc,"0","",CALL);
	}
	| postfix_expression '(' argument_expression_list ')'
	{
		//cerr << "here\n";
		sym_tab *func_symtab=gst.lookup($1->loc)->nested_table;
		vector<param*> parameters = *($3);

		vector<sym_tab_row*> params_list = func_symtab->symbols;

		bool extra=false;

		for(int i=0;i<parameters.size();i++)
		{
			//cerr << "in for\n";
			if(params_list[i]->name=="RETVAL")
				extra=true;
			/*if(parameters[i]->type.type != func_symtab->lookup(parameters[i]->name)->type.type)
			{
				string t=GST->gentemp(params_list[i]->type.type);
				QUAD_LIST.convtotype(t,params_list[i]->type.type,parameters[i]->name,parameters[i]->type.type);
				parameters[i]->name=t;
			}*/
			QUAD_LIST.emit(parameters[i]->name,"","",PARAM);
		}
		//cerr << " after for\n";
		if(extra)
		{
			//yyerror("Too many arguments");
		}
		else if(params_list.size()>parameters.size())
		{
			//yyerror("Too few arguments");
		}

		Types ret_type=func_symtab->lookup("RETVAL")->type.type;
		if(ret_type==VOID)
			QUAD_LIST.emit($1->loc,(int)parameters.size(),CALL);
		else
		{
			//cerr << " in else\n";
			string retval = GST->gentemp(ret_type);
            string siz; 
            stringstream conv;
            conv<<parameters.size(); 
            conv>>siz;
            QUAD_LIST.emit($1->loc,siz,retval,CALL);
            $$ = new expression; 
            $$->loc = retval;
		}
		//cerr << "here ends\n";
	}
	| postfix_expression '.' IDENTIFIER
	{

	}
	| postfix_expression VAL_AT IDENTIFIER
	{}
	| postfix_expression PLUS_PLUS
	{
		$$ = new expression;
		
		symbol_type t=GST->lookup($1->loc)->type;
		if(t.type==ARRAY)
		{
			$$->loc=GST->gentemp(GST->lookup($1->loc)->type.type2);
			QUAD_LIST.emit($$->loc,$1->loc,*($1->folder),ARR_IDX_ARG);
			//cerr << "array\n";
			string temp=GST->gentemp(t.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			QUAD_LIST.emit(temp,temp,"1",ADD);
			QUAD_LIST.emit($1->loc,temp,*($1->folder),ARR_IDX_RES);
			//cerr << "exot\n";
		}
		else
		{
			$$->loc=GST->gentemp(GST->lookup($1->loc)->type.type);
			//cerr << "not array \n";
			QUAD_LIST.emit($$->loc,$1->loc,"",ASSIGN);
			QUAD_LIST.emit($1->loc,$1->loc,"1",ADD);
		}

	}
	| postfix_expression MINUS_MINUS
	{
		$$ = new expression;
		$$->loc=GST->gentemp(GST->lookup($1->loc)->type.type);
		symbol_type t=GST->lookup($1->loc)->type;
		if(t.type==ARRAY)
		{
			$$->loc=GST->gentemp(GST->lookup($1->loc)->type.type2);
			string temp=GST->gentemp(t.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			QUAD_LIST.emit($$->loc,temp,"",ASSIGN);
			QUAD_LIST.emit(temp,temp,"1",SUB);
			QUAD_LIST.emit($1->loc,temp,*($1->folder),ARR_IDX_RES);
		}
		else
		{
			$$->loc=GST->gentemp(GST->lookup($1->loc)->type.type);
			QUAD_LIST.emit($$->loc,$1->loc,"",ASSIGN);
			QUAD_LIST.emit($1->loc,$1->loc,"1",SUB);
		}
	}
	| '(' type_name ')' '{' initializer_list '}'
	{}
	| '(' type_name ')' '{' initializer_list ',' '}'
	{}
	;


argument_expression_list
	: assignment_expression
	{	
	//cerr << "argument\n";
		param *first=new param;
		first->name=$1->loc;
		first->type=GST->lookup($1->loc)->type;
		$$ = new vector<param*>;
		$$->pb(first);
	}
	| argument_expression_list ',' assignment_expression
	{
		param *next = new param; 
		next->name = $3->loc; 
		next->type = GST->lookup(next->name)->type; 
		$$ = $1; 
		$$->push_back(next);
	}
	;

unary_expression
	: postfix_expression
	{
		//cerr << "came to this\n";
		//$$=$1;
	}
	| PLUS_PLUS unary_expression
	{
		$$ = new expression; 
		symbol_type type = GST->lookup($2->loc)->type;
        if(type.type == ARRAY)
        {
            string t = GST->gentemp(type.type2);
            QUAD_LIST.emit(t,$2->loc,*($2->folder),ARR_IDX_ARG);
            QUAD_LIST.emit(t,t,"1",ADD); 
            QUAD_LIST.emit($2->loc,t,*($2->folder),ARR_IDX_RES);
            $$->loc = GST->gentemp(GST->lookup($2->loc)->type.type2);
        }
        else
        {
            QUAD_LIST.emit($2->loc,$2->loc,"1",ADD); 
            $$->loc = GST->gentemp(GST->lookup($2->loc)->type.type);
        }


        $$->loc = GST->gentemp(GST->lookup($2->loc)->type.type); 
        QUAD_LIST.emit($$->loc,$2->loc,"",ASSIGN); 
	}
	| MINUS_MINUS unary_expression
	{
		$$ = new expression;
		symbol_type type = GST->lookup($2->loc)->type;
        if(type.type == ARRAY)
        {
            string t = GST->gentemp(type.type2);
            QUAD_LIST.emit(t,$2->loc,*($2->folder),ARR_IDX_ARG);
            QUAD_LIST.emit(t,t,"1",SUB); 
            QUAD_LIST.emit($2->loc,t,*($2->folder),ARR_IDX_RES);
            $$->loc = GST->gentemp(GST->lookup($2->loc)->type.type2);
        }
        else
        {
            QUAD_LIST.emit($2->loc,$2->loc,"1",SUB);
            $$->loc = GST->gentemp(GST->lookup($2->loc)->type.type); 
        }
        QUAD_LIST.emit($$->loc,$2->loc,"",ASSIGN); 
	}
	| unary_operator cast_expression
	{
		if($1 == '&')
        {
            $$ = new expression; 
            $$->loc = GST->gentemp(PTR);
           // //cerr << "reference\n";
            QUAD_LIST.emit($$->loc,$2->loc,"",REFERENCE);
        }
        else if($1 == '*')
        {
            $$ = new expression; 
            $$->loc = GST->gentemp(INT);
            $$->fold=1;
            //cerr << "taking string\n";
            $$->folder = new string($2->loc);
            //*($$->folder)=$2->loc;
           // cerr << "string taken\n";
            QUAD_LIST.emit($$->loc,$2->loc,"",DEREFERENCE);
        }
        else if($1 == '-')
        {
            $$ = new expression; 
            $$->loc = GST->gentemp();
            QUAD_LIST.emit($$->loc,$2->loc,"",U_MINUS);
        }
        else if($1 == '!')
        {
            $$=new expression;
            $$->loc=GST->gentemp(INT);
            stringstream ss;
            int temp=QUAD_LIST.next_inst+2;
            ss << temp;
            QUAD_LIST.emit(ss.str(),$2->loc,"0",GOTO_EQ);

            
            

            temp=QUAD_LIST.next_inst+3;
            stringstream ss2;
            ss2 << temp;
            QUAD_LIST.emit(ss2.str(),"","",GOTO);
            
            QUAD_LIST.emit($$->loc,"1","",ASSIGN);

            stringstream ss3;
            temp=QUAD_LIST.next_inst+2;
            ss3 << temp;
			QUAD_LIST.emit(ss3.str(),"","",GOTO);

            QUAD_LIST.emit($$->loc,"0","",ASSIGN);

        }
	}
	| SIZEOF_KEY unary_expression
	{}
	| SIZEOF_KEY '(' type_name ')'
	{}
	;

unary_operator
	: '&'
	{
		$$='&';
	}
	| '*'
	{
		$$='*';
	}
	| '+'
	{
		$$='+';
	}
	| '-'
	{
		$$='-';
	}
	| '~'
	{
		$$='~';
	}
	| '!'
	{
		$$='!';
	}
	;

cast_expression
	: unary_expression
	{
		//cerr << "unary cast\n";
	}
	| '(' type_name ')' cast_expression
	{

	}
	;

multiplicative_expression
	: cast_expression
	{
		$$=new expression;
		//cerr << "in multiplica " << $1->loc << "\n";
		symbol_type t1 = GST->lookup($1->loc)->type;
        if(t1.type == ARRAY)
        {

        	//cerr<<"hi there\n";
            string t = GST->gentemp(t1.type2);
            ////cerr<<"end\n";
            if($1->folder!=NULL)
            {
	            //cerr<<"lol-"<<*($1->folder)<<endl;
	            QUAD_LIST.emit(t,$1->loc,*($1->folder),ARR_IDX_ARG);
	            //cerr<<"edning here\n";

	            $1->loc = t; 
	            $1->type = t1.type2;
	            $$=$1;
	        }
	        else
	        	$$=$1;

            //cerr<<"edning here\n";
            
        }
        else
        {
        	//cerr << "not array\n"; 
            $$ = $1;
        }
           //cerr << "ending\n";	
	}
	| multiplicative_expression '*' cast_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		Types final;
		
		if(one->type.type > two->type.type)
		{
			final=one->type.type;
		}
		else
		{
			final=two->type.type;			
		}
			
		
		$$->loc=GST->gentemp(final);
		QUAD_LIST.emit($$->loc,$1->loc,$3->loc,MULT);
		

	}
	| multiplicative_expression '/' cast_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		Types final;
		
		if(one->type.type > two->type.type)
		{
			final=one->type.type;
		}
		else
		{
			final=two->type.type;			
		}
			
		
		$$->loc=GST->gentemp(final);
		QUAD_LIST.emit($$->loc,$1->loc,$3->loc,DIV);
	}
	| multiplicative_expression '%' cast_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		Types final;
		
		if(one->type.type > two->type.type)
		{
			final=one->type.type;
		}
		else
		{
			final=two->type.type;			
		}
			
		
		$$->loc=GST->gentemp(final);
		QUAD_LIST.emit($$->loc,$1->loc,$3->loc,MOD);
	}
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		Types final;
		
		if(one->type.type > two->type.type)
		{
			final=one->type.type;
		}
		else
		{
			final=two->type.type;			
		}
			
		
		$$->loc=GST->gentemp(final);
		QUAD_LIST.emit($$->loc,$1->loc,$3->loc,ADD);
	}
	| additive_expression '-' multiplicative_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		Types final;
		
		if(one->type.type > two->type.type)
		{
			final=one->type.type;
		}
		else
		{
			final=two->type.type;			
		}
			
		
		$$->loc=GST->gentemp(final);
		QUAD_LIST.emit($$->loc,$1->loc,$3->loc,SUB);
	}
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_SHIFT additive_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		$$->loc=GST->gentemp(one->type.type);
		QUAD_LIST.emit($$->loc,$1->loc,$3->loc,SL);
	}
	| shift_expression RIGHT_SHIFT additive_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		$$->loc=GST->gentemp(one->type.type);
		QUAD_LIST.emit($$->loc,$1->loc,$3->loc,SR);
	}
	;

relational_expression
	: shift_expression
	| relational_expression '<' shift_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		$$ = new expression; 
        $$->loc = GST->gentemp();
        $$->type = BOOL; 
        QUAD_LIST.emit($$->loc,"1","",ASSIGN); 
        $$->TL = makelist(QUAD_LIST.next_inst); 
        QUAD_LIST.emit("",$1->loc,$3->loc,GOTO_LT); 
        QUAD_LIST.emit($$->loc,"0","",ASSIGN);  
        $$->FL = makelist(QUAD_LIST.next_inst); 
        QUAD_LIST.emit("","","",GOTO);
	}
	| relational_expression '>' shift_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		$$ = new expression; 
        $$->loc = GST->gentemp();
        $$->type = BOOL; 
        QUAD_LIST.emit($$->loc,"1","",ASSIGN); 
        $$->TL = makelist(QUAD_LIST.next_inst); 
        QUAD_LIST.emit("",$1->loc,$3->loc,GOTO_GT); 
        QUAD_LIST.emit($$->loc,"0","",ASSIGN);  
        $$->FL = makelist(QUAD_LIST.next_inst); 
        QUAD_LIST.emit("","","",GOTO);
	}
	| relational_expression LESS_THAN_EQUAL shift_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		$$ = new expression; 
        $$->loc = GST->gentemp();
        $$->type = BOOL; 
        QUAD_LIST.emit($$->loc,"1","",ASSIGN); 
        $$->TL = makelist(QUAD_LIST.next_inst); 
        QUAD_LIST.emit("",$1->loc,$3->loc,GOTO_LTE); 
        QUAD_LIST.emit($$->loc,"0","",ASSIGN);  
        $$->FL = makelist(QUAD_LIST.next_inst); 
        QUAD_LIST.emit("","","",GOTO);
	}
	| relational_expression GREATER_THAN_EQUAL shift_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		$$ = new expression; 
        $$->loc = GST->gentemp();
        $$->type = BOOL; 
        QUAD_LIST.emit($$->loc,"1","",ASSIGN); 
        $$->TL = makelist(QUAD_LIST.next_inst); 
        QUAD_LIST.emit("",$1->loc,$3->loc,GOTO_GTE); 
        QUAD_LIST.emit($$->loc,"0","",ASSIGN);  
        $$->FL = makelist(QUAD_LIST.next_inst); 
        QUAD_LIST.emit("","","",GOTO);
	}
	;

equality_expression
	: relational_expression
	{
		$$=new expression;
		$$=$1;
	}
	| equality_expression EQUAL_EQUAL relational_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		$$ = new expression; 
        $$->loc = GST->gentemp();
        $$->type = BOOL; 
        QUAD_LIST.emit($$->loc,"1","",ASSIGN); 
        $$->TL = makelist(QUAD_LIST.next_inst); 
        QUAD_LIST.emit("",$1->loc,$3->loc,GOTO_EQ); 
        QUAD_LIST.emit($$->loc,"0","",ASSIGN);  
        $$->FL = makelist(QUAD_LIST.next_inst); 
        QUAD_LIST.emit("","","",GOTO);
	}
	| equality_expression NOT_EQUAL relational_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		$$ = new expression; 
        $$->loc = GST->gentemp();
        $$->type = BOOL; 
        QUAD_LIST.emit($$->loc,"1","",ASSIGN); 
        $$->TL = makelist(QUAD_LIST.next_inst); 
        QUAD_LIST.emit("",$1->loc,$3->loc,GOTO_NEQ); 
        QUAD_LIST.emit($$->loc,"0","",ASSIGN);  
        $$->FL = makelist(QUAD_LIST.next_inst); 
        QUAD_LIST.emit("","","",GOTO);
	}
	;

and_expression
	: equality_expression
	{
		
	}
	| and_expression '&' equality_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		$$ = new expression; 
        $$->loc = GST->gentemp();
       	QUAD_LIST.emit($$->loc,$1->loc,$3->loc,BW_AND);
	}
	;

exclusive_or_expression
	: and_expression
	{
		$$=$1;
	}
	| exclusive_or_expression '^' and_expression
	{
		
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		$$ = new expression; 
        $$->loc = GST->gentemp();
       	QUAD_LIST.emit($$->loc,$1->loc,$3->loc,BW_XOR);
	}
	;

inclusive_or_expression
	: exclusive_or_expression
	{
		$$=new expression;
		$$=$1;
	}
	| inclusive_or_expression '|' exclusive_or_expression
	{
		$$=new expression();
		sym_tab_row *one=GST->lookup($1->loc);
		sym_tab_row *two=GST->lookup($3->loc);

		if(two->type.type==ARRAY)
		{
			string temp=GST->gentemp(two->type.type2);
			QUAD_LIST.emit(temp,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp;
			$3->type=two->type.type2;
		}

		if(one->type.type==ARRAY)
		{
			string temp=GST->gentemp(one->type.type2);
			QUAD_LIST.emit(temp,$1->loc,*($1->folder),ARR_IDX_ARG);
			$1->loc=temp;
			$1->type=one->type.type2;
		}

		$$ = new expression; 
        $$->loc = GST->gentemp();
       	QUAD_LIST.emit($$->loc,$1->loc,$3->loc,BW_OR);
	}
	;

logical_and_expression
	: inclusive_or_expression
	{
	}
	| logical_and_expression LOGICAL_AND M inclusive_or_expression
	{
		QUAD_LIST.backpatch($1->TL,$3->instr);
		$$->FL=merge($1->FL,$4->FL);
		$$->TL=$4->TL;
		$$->type=BOOL;
	}
	;

logical_or_expression
	: logical_and_expression
	{
	}
	| logical_or_expression LOGICAL_OR M logical_and_expression
	{
		QUAD_LIST.backpatch($1->FL,$3->instr);
		$$->TL=merge($1->TL,$4->TL);
		$$->FL=$4->FL;
		$$->type=BOOL;
	}
	;

conditional_expression
	: logical_or_expression
	{
		$$=$1;
	}
	| logical_or_expression N '?' M expression N ':' M conditional_expression
	{
		sym_tab_row* one=GST->lookup($5->loc);
		$$->loc=GST->gentemp(one->type.type);
		$$->type=one->type.type;
		QUAD_LIST.emit($$->loc,$9->loc,"",ASSIGN);
		list<int> temp=makelist(QUAD_LIST.next_inst);
		QUAD_LIST.emit("","","",GOTO);
		QUAD_LIST.backpatch($6->NL,QUAD_LIST.next_inst);
		QUAD_LIST.emit($$->loc,$5->loc,"",ASSIGN);
		temp=merge(temp,makelist(QUAD_LIST.next_inst));
		QUAD_LIST.emit("","","",GOTO);
		QUAD_LIST.backpatch($2->NL,QUAD_LIST.next_inst);
		QUAD_LIST.convInttoBool($1);
		QUAD_LIST.backpatch($1->TL,$4->instr);
		QUAD_LIST.backpatch($1->FL,$8->instr);
		QUAD_LIST.backpatch($2->NL,QUAD_LIST.next_inst);
	}
	;

assignment_expression
	: conditional_expression
	{
		
	}
	| unary_expression assignment_operator assignment_expression
	{
		////cerr << $3->loc << "\n";
		sym_tab_row *temp=GST->lookup($3->loc);
		/*if(temp->type.type==ARRAY)
		{
			//cerr << "came here \n";
			string temp2=GST->gentemp(temp->type.type2);
			//cerr << temp2 << endl;
			QUAD_LIST.emit(temp2,$3->loc,*($3->folder),ARR_IDX_ARG);
			$3->loc=temp2;
			$3->type=temp->type.type2;
		}*/
		sym_tab_row *temp1=GST->lookup($1->loc);
		if($1->fold==0)
		{
			if(temp1->type.type != ARRAY)
			{
				////cerr << "not array " << $1->loc << endl;
				QUAD_LIST.emit($1->loc,$3->loc,"",ASSIGN);
			}
			else
			{
				////cerr << "array " << $1->loc << endl ;
				QUAD_LIST.emit($1->loc,$3->loc,*($1->folder),ARR_IDX_RES);
			}
		}
		else
		{
			//cerr << "l deref\n";
			QUAD_LIST.emit(*($1->folder),$3->loc,"",L_DEREF);
		}
		$$=$1;
	}
	;

assignment_operator
	: '='
	{}
	|MULTIPLY_EQUAL
	{}
	|DIVIDE_EQUAL
	{}
    |MODULO_EQUAL
    {}
    |PLUS_EQUAL
    {}
    |MINUS_EQUAL
    {}
    |LEFT_SHIFT_EQUAL
    {}
    |RIGHT_SHIFT_EQUAL
    {}
    |AND_EQUAL
    {}
    |BITWISENOT_EQUAL
    {}
    |OR_EQUAL
    {}
	;

expression
	: assignment_expression
	{
	}
	| expression ',' assignment_expression
	{}
	;

constant_expression
	: conditional_expression
	{}
	;

declaration
	: declaration_specifiers init_declarator_list ';'
	{
		Types curr_type=$1;
		int curr_size=-1;
		if(curr_type==INT)
			curr_size=size_of_int;
		else if(curr_type==CHAR)
			curr_size=size_of_char;
		else if(curr_type==DOUBLE)
			curr_size=size_of_double;
		vector<declarations*> list=*($2);
		for (vector<declarations*>::iterator it = list.begin(); it != list.end(); ++it)
		{
			declarations *curr_dec=*it;
			////cerr << "name " << curr_dec->name << endl;
			if(curr_dec->type == FUNCTION)
			{
				GST=&(gst);
				QUAD_LIST.emit(curr_dec->name,"","",FUNC_END);

				sym_tab_row *one=GST->lookup(curr_dec->name);
				sym_tab_row *two=one->nested_table->lookup("RETVAL",curr_type,curr_dec->pointers);
				one->size=0;
				//one->offset=GST->offset;
				one->init_val=NULL;
				continue;
			}

			sym_tab_row *three=GST->lookup(curr_dec->name,curr_type);
			three->nested_table=NULL;
			if(curr_dec->list == vector<int>() && curr_dec->pointers == 0) 
            {
                three->type.type = curr_type;
                //three->offset = GST->offset; 
                //three->offset += curr_size;
                three->size = curr_size;
                if(curr_dec->init_val != NULL)
                {
                    string rval = curr_dec->init_val->loc;
                    QUAD_LIST.emit(three->name, rval,"",ASSIGN);
                    three->init_val = GST->lookup(rval)->init_val;
                }
                else
                    three->init_val = NULL;
            }
            else if(curr_dec->list!=vector<int>())
            {
                three->type.type = ARRAY;
                three->type.type2 = curr_type;
                three->type.dims = curr_dec->list;
                //three->offset = GST->offset;
                int sz = curr_size; vector<int> tmp = three->type.dims; int tsz = tmp.size();
                for(int i = 0; i<tsz; i++) sz *= tmp[i];
                    GST->offset += sz;
                three->size = sz;
                GST->offset-=4;
            }
            else if(curr_dec->pointers != 0)
            {
                three->type.type = PTR;
                three->type.type2 = curr_type;
                three->type.pointers = curr_dec->pointers;
                //three->offset = GST->offset; 
                GST->offset += size_of_pointer - curr_size;
                three->size = size_of_pointer;
            }
		}
		
	}
	| declaration_specifiers ';'
	;



declaration_specifiers
	 : storage_class_specifier
	 {}
    | storage_class_specifier declaration_specifiers
    {}
    | type_specifier
    {}                               
    | type_specifier declaration_specifiers
    {}
    | type_qualifier
    {}
    | type_qualifier declaration_specifiers
    {}
    | function_specifier
    {}
    | function_specifier declaration_specifiers
    {}
    ;



init_declarator_list
	: init_declarator
	{
		//vector<declaration*> v;
		$$ = new vector<declarations*>;
		$$->pb($1);
	}
	| init_declarator_list ',' init_declarator
	{
		$1->pb($3);
		$$=$1;
	}
	;

init_declarator
	: declarator
	{
		$$=$1;
		$$->init_val=NULL;
	}
	| declarator '=' initializer
	{
		$$=$1;
		$$->init_val=$3;
	}
	;
storage_class_specifier
	:TYPEDEF_KEY
	{}
	| EXTERN_KEY
	{}
	| STATIC_KEY
	{}
	| AUTO_KEY
	{}
	| REGISTER_KEY
	{}
	;

type_specifier
	: VOID_KEY
	{
		$$=VOID;
	}
	| CHAR_KEY
	{
		$$=CHAR;
	}
	| SHORT_KEY
	{}
	| INT_KEY
	{
		$$=INT;
	}
	| LONG_KEY
	{}
	| FLOAT_KEY
	{}
	| DOUBLE_KEY
	{
		$$=DOUBLE;
	}
	| SIGNED_KEY
	{}
	| UNSIGNED_KEY
	{}
	| BOOL_KEY
	{}
	| COMPLEX_KEY
	{}
	| IMAGINARY_KEY
	{}
	| enum_specifier
	{}
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list_opt
	{}
	| type_qualifier specifier_qualifier_list_opt
	{}
	;

specifier_qualifier_list_opt
	: specifier_qualifier_list
	{}
	|
	{}
	;

enum_specifier
	: ENUM_KEY '{' enumerator_list '}'
	{}
	| ENUM_KEY IDENTIFIER '{' enumerator_list '}'
	{}
	| ENUM_KEY '{' enumerator_list ',' '}'
	{}
	| ENUM_KEY IDENTIFIER '{' enumerator_list ',' '}'
	{}
	| ENUM_KEY IDENTIFIER
	{}
	;

enumerator_list
	: enumerator
	{}
	| enumerator_list ',' enumerator
	{}
	;

enumerator
	: ENUMERATION
	{}
	| ENUMERATION '=' constant_expression
	{}
	;

type_qualifier
	: CONST_KEY
	{}
	| RESTRICT_KEY
	{}
	| VOLATILE_KEY
	{}
	;

function_specifier
	: INLINE_KEY
	{}
	;

declarator
	: pointer direct_declarator
	{
		$$=$2;
		$$->pointers=$1;
	}
	| direct_declarator
	{
		$$=$1;
		$$->pointers=0;
	}
	;


direct_declarator
	: IDENTIFIER
	{
		$$=new declarations;
		$$->name=*($1);
	}
	| '(' declarator ')'
	{}
	| direct_declarator '[' type_qualifier_list_opt ']'
	{
		//cerr << "dkhbv"<< $1->name << "\n";
		
		$1->type=ARRAY;
		$1->type2=INT;
		$$=$1;
		int index;
		index=0;
		$$->list.pb(index);
		//cerr << "dkhbv2\n";
	}
	| direct_declarator '[' type_qualifier_list_opt assignment_expression ']'
	{
		//cerr << "dkhbv"<< $1->name << "\n";
		
		$1->type=ARRAY;
		$1->type2=INT;
		$$=$1;
		int index;
		 index=GST->lookup($4->loc)->init_val->a;
		$$->list.pb(index);
		//cerr << "dkhbv2\n";
	}
	| direct_declarator '[' STATIC_KEY type_qualifier_list_opt assignment_expression ']'
	{

	}
	| direct_declarator '[' type_qualifier_list STATIC_KEY assignment_expression ']'
	{}	
	| direct_declarator '[' type_qualifier_list_opt '*' ']'
	{
		$1->type=PTR;
		$1->type2=INT;
		$$=$1;
	}
	| direct_declarator '(' parameter_type_list_opt ')'
	{
		//cerr << "function def ends\n";
		$$ = $1;

        $$->type = FUNCTION;
        sym_tab_row *function_data = GST->lookup($$->name,$$->type);
        sym_tab *function_sym_tab = new sym_tab;
        function_data->nested_table = function_sym_tab;
       vector<param*> param_list=*($3);
        for(int i = 0;i<param_list.size(); i++)
        {
            param *curr_param = param_list[i];
            if(curr_param->type.type==ARRAY)
            {
            	//cerr << "array was entered\n";
				function_sym_tab->lookup(curr_param->name,curr_param->type.type);
				function_sym_tab->lookup(curr_param->name)->type.type2=INT;
				function_sym_tab->lookup(curr_param->name)->type.dims.pb(0);
            }
            else if(curr_param->type.type==PTR)
            {
            	cerr << "pointer was made\n";
            	function_sym_tab->lookup(curr_param->name,curr_param->type.type);
				function_sym_tab->lookup(curr_param->name)->type.type2=INT;
				function_sym_tab->lookup(curr_param->name)->type.dims.pb(0);
            }
			else
				function_sym_tab->lookup(curr_param->name,curr_param->type.type);
        }
        
        GST = function_sym_tab;
        QUAD_LIST.emit($$->name,"","",FUNC_BEG);

	}
	| direct_declarator '(' identifier_list ')'
	{}
	;
parameter_type_list_opt
	:
	{
		$$ =new vector <param*>;
	}
	| parameter_type_list
	{}
	;

pointer
	: '*' type_qualifier_list
	{}
	| '*'
	{
		$$=1;
	}
	| '*' type_qualifier_list pointer
	{}
	| '*' pointer
	{
		$$=1+$2; 
	}
	;

type_qualifier_list_opt
	: type_qualifier_list
	{}
	|
	{}
	;

type_qualifier_list
	: type_qualifier
	{}
	| type_qualifier_list type_qualifier
	{}
	;


parameter_type_list
	: parameter_list
	
	| parameter_list ',' ELLIPSES
	
	;

parameter_list
	: parameter_declaration
	{
		$$ = new vector<param*>; 
		$$->push_back($1);
	}
	| parameter_list ',' parameter_declaration
	{
		$1->push_back($3);
		 $$ = $1;
	}
	;

parameter_declaration
	: declaration_specifiers declarator
	{
		$$=new param;
		$$->name=$2->name;
		if($2->type==ARRAY)
		{
			//cerr << "type set to array\n";
			$$->type.type=ARRAY;
			$$->type.type2=$1;
		}
		else if($2->pc!=0)
		{
			$$->type.type=PTR;
			$$->type.type2=$1;
		}
		else
		{
			$$->type.type=$1;
		}
	}
	| declaration_specifiers
	{}
	;

identifier_list
	: IDENTIFIER
	{}
	| identifier_list ',' IDENTIFIER
	{}
	;

type_name
	: specifier_qualifier_list
	{}
	;

initializer
	: assignment_expression
	{
		$$=$1;
	}
	| '{' initializer_list '}'
	{}
	| '{' initializer_list ',' '}'
	{}
	;

initializer_list
	: designation_opt initializer
	{}
	| initializer_list ',' designation_opt initializer
	{}
	;

designation_opt
	: designation
	{}
	|
	{}
	;

designation
	: designator_list '='
	{}
	;

designator_list
	: designator
	{}
	| designator_list designator
	{}
	;

designator
	: '[' constant_expression ']'
	{}
	| '.' IDENTIFIER
	{}
	;

statement
	: labeled_statement
	{}
		| compound_statement
		| expression_statement
		| selection_statement
		| iteration_statement
		| jump_statement
		;

labeled_statement
	: IDENTIFIER ':' statement
	{}
	| CASE_KEY constant_expression ':' statement
	{}
	| DEFAULT_KEY ':' statement
	{}
	;

compound_statement
	: '{' '}'
	{}
	| '{' block_item_list '}'
	{
		$$=$2;
	}
	;

block_item_list
	: block_item
	{
		$$=$1;
		QUAD_LIST.backpatch($1->NL,QUAD_LIST.next_inst);
	}
	| block_item_list M block_item
	{
		$$ = new expression;
		QUAD_LIST.backpatch($1->NL,$2->instr);
		$$->NL=$3->NL;
	}
	;

block_item
	: declaration
	{
		$$ = new expression;

	}
	| statement
	
	;

expression_statement
	: ';'
	{
		$$=new expression;
	}
	| expression ';'
	{
		//$$=$1;
	}
	;

selection_statement
	: IF_KEY '(' expression N ')' M statement N
	{
		QUAD_LIST.backpatch($4->NL,QUAD_LIST.next_inst);
		QUAD_LIST.convInttoBool($3);
		QUAD_LIST.backpatch($3->TL,$6->instr);
		$$ = new expression;
		$7->NL=merge($8->NL,$7->NL);
		$$->NL=merge($3->FL,$7->NL);

	}
	| IF_KEY '(' expression N ')' M statement N ELSE_KEY  M statement N
	{
		QUAD_LIST.backpatch($4->NL,QUAD_LIST.next_inst);
        QUAD_LIST.convInttoBool($3);
        QUAD_LIST.backpatch($3->TL,$6->instr);
        QUAD_LIST.backpatch($3->FL,$10->instr);
        $$ = new expression;
        $$->NL = merge($7->NL,$8->NL);        
        $$->NL = merge($$->NL,$11->NL);  
        $$->NL=merge($$->NL,$12->NL); 
	}
	| SWITCH_KEY '(' expression ')' statement
	{

	}
	;

iteration_statement
	: WHILE_KEY M '(' expression N ')' M statement
	{
		////cerr << "while mai ghusa\n";
		$$ = new expression;
		
		////cerr << "while mai ghusa\n";
		QUAD_LIST.emit("","","",GOTO);
		QUAD_LIST.backpatch(makelist(QUAD_LIST.next_inst-1),$2->instr);
		QUAD_LIST.backpatch($5->NL,QUAD_LIST.next_inst);
		QUAD_LIST.convInttoBool($4);
		$$->NL=$4->FL;

		QUAD_LIST.backpatch($4->TL,$7->instr);
		QUAD_LIST.backpatch($8->NL,$2->instr);
	}
	| DO_KEY M statement M WHILE_KEY '(' expression N ')' ';'
	{
		$$=new expression;
		QUAD_LIST.backpatch($8->NL,QUAD_LIST.next_inst);
		QUAD_LIST.convInttoBool($7);
		QUAD_LIST.backpatch($7->TL,$2->instr);
		QUAD_LIST.backpatch($3->NL,$4->instr);
		$$->NL=$7->FL;
	}
	| FOR_KEY '(' expression_statement M expression_statement N M expression N ')' M statement
	{
		$$=new expression;
		
		QUAD_LIST.emit("","","",GOTO);
		$12->NL=merge($12->NL,makelist(QUAD_LIST.next_inst-1));
		QUAD_LIST.backpatch($12->NL,$7->instr);
		QUAD_LIST.backpatch($9->NL,$4->instr);
		QUAD_LIST.backpatch($6->NL,QUAD_LIST.next_inst);
		QUAD_LIST.convInttoBool($5);
		QUAD_LIST.backpatch($5->TL,$11->instr);
		$$->NL=$5->FL;
	}
	;



jump_statement
	: GOTO_KEY IDENTIFIER ';'
	{}
	| CONTINUE_KEY ';'
	{}
	| BREAK_KEY ';'
	{}
	| RETURN_KEY ';'
	{
		if(GST->lookup("RETVAL")->type.type==VOID)
			QUAD_LIST.emit("","","",RETURN);
		else
			//yyerror("return type is not void\n");
		$$=new expression;
	}
	| RETURN_KEY expression ';'
	{
		if(GST->lookup("RETVAL")->type.type == GST->lookup($2->loc)->type.type)
        {
            QUAD_LIST.emit($2->loc,"","",RETURN);
        }
        $$ =new expression;
	}
	;

translation_unit
    : external_declaration
    {
    ////cerr << "1\n";
    }
    | translation_unit external_declaration
    {
    ////cerr << "2\n";
    }
    ;

external_declaration
    : function_definition
    {
    ////cerr << "3\n";
    	////cerr << "dncjownc\n";
    }
    | declaration
    {
    	////cerr << "4\n";
    }
    ;

function_definition
    : declaration_specifiers declarator declaration_list compound_statement
    {
    ////cerr << "5\n";
    }
    | function_prototype compound_statement
    {
    	////cerr << "6\n";
        GST = &(gst);
        QUAD_LIST.emit($1->name,"","",FUNC_END);
    }
    
    ;

declaration_list
    :declaration
    {
    ////cerr << "7\n";
    }
    |declaration_list declaration
    {
    ////cerr << "8\n";
    }
    ;


N
	:                                              
	{
		$$ =  new expression;  
		$$->NL = makelist(QUAD_LIST.next_inst); 
		QUAD_LIST.emit("","","",GOTO);
	}
	;

// M is introduced to be a marker for an entry point to starting of parsed Quad code
M
	:                                                   
	{	
		$$ =  new expression; 
		$$->instr = QUAD_LIST.next_inst;
	}
	;


function_prototype
    :declaration_specifiers declarator
    {
       ////cerr << "akdhbcksjnbv\n";
        Types curr_type = $1;
        int curr_size = -1;
        if(curr_type == CHAR) curr_size = size_of_char;
        if(curr_type == INT)  curr_size = size_of_int;
        if(curr_type == DOUBLE)  curr_size = size_of_double;        
        
        declarations *curr_dec = $2;
        sym_tab_row *three = gst.lookup(curr_dec->name);
        if(curr_dec->type == FUNCTION) 
        {
            sym_tab_row *retval = three->nested_table->lookup("RETVAL",curr_type,curr_dec->pointers);
            
            //three->offset = GST->offset;
            three->size = 0;
            three->init_val = NULL;           
        }
        $$ = $2;
    }
    ;
%%

void yyerror(string s) {
	////cerr << s << "\n";
}

int main()
{
   //yydebug = 1;
    bool failure = yyparse();  
    int sz = QUAD_LIST.list_of_quads.size();
    
    
    for(int i = 0; i<sz;i++)
    {
        cout<<i<<": "; QUAD_LIST.list_of_quads[i].print_quad();
    }
    

    
    cout<<"----------------SYMBOL TABLE----------------"<<endl;
    GST->print_symtab();
    cout<<"--------------------------------------------"<<endl;
    for(map<string,sym_tab_row*> :: iterator it = GST->symbol_table.begin(); it != GST->symbol_table.end(); ++it)
    {
        sym_tab_row *tmp = it->second;
        if(tmp->nested_table != NULL)
        {
            cout<<"----------------SYMBOL TABLE ( "<<tmp->name<<" )----------------"<<endl;
            tmp->nested_table->print_symtab();
            cout<<"--------------------------------------------"<<endl;
        }
    }
    
    
    
    if(failure)
        printf("failure\n");
    else
        printf("success\n");
     

    GST=&gst;
    gencode();
}
