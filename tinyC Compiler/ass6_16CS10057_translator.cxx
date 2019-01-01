#include "ass6_16CS10057_translator.h"

quads::quads(string res,string arg1,string arg2,opcode op)
{
	this->res=res;
	this->arg1=arg1;
	this->arg2=arg2;
	this->op=op;
}

void quads::print_quad()
{

	if(ADD<=op && op<=BW_XOR)
	{
		cout << res << " = " << arg1 << " ";
		switch(op)
		{
			case ADD: cout<<"+";
			break; 
            case SUB: cout<<"-";
			break;
            case MULT: cout<<"*"; 
			break;
            case DIV: cout<<"/"; 
			break;
            case MOD: cout<<"%"; 
			break;
            case SL: cout<<"<<"; 
			break;
            case SR: cout<<">>";   
			break;
            case LT: cout<<"<"; 
			break;
            case GT: cout<<">"; 
			break;
            case EQ: cout<<"=="; 
			break;
            case NEQ: cout<<"!="; 
			break;
            case LTE: cout<<"<="; 
			break;
            case GTE: cout<<">="; 
			break;
            case LOG_AND: cout<<"&&"; 
			break;
            case LOG_OR: cout<<"||"; 
			break;
            case BW_XOR: cout<<"^"; 
			break;
            case BW_AND: cout<<"&"; 
			break;
            case BW_OR: cout<<"|"; 
			break;
		}
		cout << " " << arg2<<"\n";
	}
	else if(BW_U_NOT <= op && op<=ASSIGN)
	{
		cout << res<< " = ";
		switch(op)
		{
			case U_MINUS : cout<<"-";
			break; 
            case U_PLUS : cout<<"+"; 
			break;
            case BW_U_NOT : cout<<"~"; 
			break;
            case U_NEG : cout<<"!"; 
			break;
            case ASSIGN : cout<<""; 
			break;
			case REFERENCE : cout <<"&";
			break;
			case DEREFERENCE : cout <<"*";
		}
		cout << arg1 << endl;
	}
	else if(op==GOTO)
	{
		cout << "goto " << res << endl;
	}
	else if(GOTO_EQ<=op && op<=IF_FALSE_GOTO)
	{
		cout << "if " << arg1 << " ";
		switch(op)
		{
			case   GOTO_LT : cout<<"< ";
			break;
            case   GOTO_GT : cout<<"> "; 
            break;
            case   GOTO_LTE : cout<<"<= "; 
            break;
            case   GOTO_GTE : cout<<">= "; 
            break;
            case   GOTO_EQ : cout<<"== "; 
            break;
            case   GOTO_NEQ : cout<<"!= "; 
            break;
            case   IF_GOTO : cout<<"!= 0"; 
            break;
            case   IF_FALSE_GOTO : cout<<"== 0"; 
            break;
		}
		cout << arg2 << "goto " << res << endl;
	}
	else if(CtoI<=op && op<=CtoD)
	{
		cout<<res<<" = ";
        switch(op)
        {
            case CtoI : cout<<" ChartoInt("<<arg1<<")"<<endl; 
            break;
            case CtoD : cout<<" ChartoDouble("<<arg1<<")"<<endl; 
            break;
            case ItoC : cout<<" InttoChar("<<arg1<<")"<<endl; 
            break;
            case DtoC : cout<<" DoubletoChar("<<arg1<<")"<<endl; 
            break;
            case ItoD : cout<<" InttoDouble("<<arg1<<")"<<endl; 
            break;
            case DtoI : cout<<" DoubletoInt("<<arg1<<")"<<endl; 
            break;
        }  
	}
	else if(op==RETURN)
	{
		cout << "return " << res << "\n";
	}
	else if(op == PARAM)
	{
		cout << "param " << res << endl;
	}
	else if(op==CALL)
	{
		if(arg2.size()>0)
			cout << arg2 << " = ";
		cout << "call " << res << " " << arg1 << "\n";
	}
	else if(op==ARR_IDX_ARG)
	{
		cout << res << " = " << arg1 << "[" << arg2 << "]" <<"\n";
	}
	else if(op==ARR_IDX_RES)
	{
		cout << res << "[" << arg2 << "] = " << arg1 << "\n"; 
	}
	else if(op == FUNC_BEG)
    {
        //cout<<"func "<<res<<" starts"<<endl;
        cout << res << ": \n";
    }
   	else if(op == FUNC_END)
   	{
   		cout << "function " << res << " ends\n";
   	}
    else if(op == REFERENCE)
    {
    	//cout << "referenceh\n";
        cout<<res<<" = &"<<arg1<<endl;
    }
    else if(op == DEREFERENCE)
    {
        cout<<res<<" = *"<<arg1<<endl;
    }
    else if(op == L_DEREF)
    {
    	cout << "*" << res << " = " << arg1 << "\n";
    }
	else
	{
		cout << "akjscnald\n";
		cout << res << " = " << arg1 << "( " << op <<" ) " << arg2 << "\n";
	}
}

void quad_array::emit(string res, string arg1, string arg2, opcode op)
{

    quads insert(res,arg1,arg2,op);
    list_of_quads.pb(insert);
    next_inst++;
}

void quad_array::emit(string res, int constant, opcode U_op)
{
	stringstream conv; 
    conv << constant;
    quads insert(res,conv.str(),"",U_op);
    list_of_quads.pb(insert); 
    next_inst++;
}

void quad_array::emit(string res, double constant, opcode U_op)
{
    stringstream conv; 
    conv << constant;
    quads insert(res,conv.str(),"",U_op);
    list_of_quads.pb(insert); 
    next_inst++;
}

void quad_array::emit(string res, char constant, opcode U_op)
{
    stringstream conv; 
    conv << constant;
    quads insert(res,conv.str(),"",U_op);
    list_of_quads.pb(insert); 
    next_inst++;   
}

void quad_array::backpatch(list<int> dang, int idx)
{
	for (list<int>::iterator it = dang.begin(); it != dang.end(); ++it)
	{
		stringstream conv;
		conv << idx;
		conv >> list_of_quads[*it].res;
	}
}

void quad_array::convInttoBool(expression* res)
{
    
    if(res->type == BOOL) 
    {
    	
    	return;
    }
    res->FL = makelist(next_inst);
    emit("",res->loc,"",IF_FALSE_GOTO);
    res->TL = makelist(next_inst);
    emit("","","",GOTO);
    res->type = BOOL;
    return;
}
void quad_array::convtotype(expression *t, expression *res, Types to_conv)
{
	if(res->type == to_conv)
		return;
	if(res->type == DOUBLE)
	{
		if(to_conv == INT)
		{
			emit(t->loc,res->loc,"",DtoI);
		}
		else
			emit(t->loc,res->loc,"",DtoC);
	}
	else if(res->type == INT)
	{
		if(to_conv == DOUBLE)
		{
			emit(t->loc,res->loc,"",ItoD);
		}
		else
			emit(t->loc,res->loc,"",ItoC);
	}
	else
	{
		if(to_conv == DOUBLE)
		{
			emit(t->loc,res->loc,"",CtoD);
		}
		else
			emit(t->loc,res->loc,"",CtoI);
	}
}
void quad_array::convtotype(string t,Types to, string f, Types from)
{
    if(to == from)
    	return;
    if(from == DOUBLE)
    {
    	if(to == INT)
    	{
    		emit(t,f,"",DtoI);
    	}
    	else
    		emit(t,f,"",DtoC);
    }
    else if(from == INT)
    {
    	if(to == DOUBLE)
    	{
    		emit(t,f,"",ItoD);
    	}
    	else
    		emit(t,f,"",ItoC);
    }
    else
    {
    	if(to == DOUBLE)
    	{
    		emit(t,f,"",CtoD);
    	}
    	else
    		emit(t,f,"",CtoI);
    }
}

sym_tab_row* sym_tab::lookup(string var,Types t,int count1)
{
	if(symbol_table.count(var)!=0)
	{
		return symbol_table[var];
	}
	else
	{
		sym_tab_row *insert=new sym_tab_row;
		insert->name=var;
		insert->type.type=t;
		insert->offset=offset;
		insert->init_val=NULL;
		//printf("variable made\n");
		if(count1!=0)
		{
			//cerr << "var is " << var << "\n";
			insert->size=size_of_pointer;
			//offset+=size_of_pointer;
			insert->type.type=ARRAY;
			insert->type.type2=t;
			insert->type.pointers=count1;	
		}
		else
		{
			if(t == INT)
			{
				
				insert->size= size_of_int;
				offset+=size_of_int;
			}
			else if(t == DOUBLE)
			{
				insert->size = size_of_double;
				offset+=size_of_double;
			}
			else if(t == CHAR)
			{
				insert->size = size_of_char;
				offset+=size_of_char;
			}
			else if(t==PTR)
			{
				//cerr << "var is " << var << "\n";
				insert->size = size_of_pointer;
				offset+=size_of_pointer;
			}
			else
			{
				insert->size=0;
				offset+=0;
			}
		}
		symbol_table[var]=insert;
		symbols.pb(insert);
	
		return symbol_table[var];
	}
}

string sym_tab::gentemp(Types t)
{
	static int total_temps=0;
	stringstream temp_name_temp;
	temp_name_temp << "t" << total_temps++;
	string temp_name;
	temp_name_temp >> temp_name;
	sym_tab_row *insert=new sym_tab_row;
	//printf("temporary generated \n");
	
	insert->name=temp_name;
	insert->type.type=t;
	insert->offset=offset;
	insert->init_val=NULL;
	//cout << temp_name << "  " << insert->offset <<  endl;
	if(t == INT)
	{
		insert->size= size_of_int;
		offset+=size_of_int;
	}
	else if(t == DOUBLE)
	{
		insert->size = size_of_double;
		offset+=size_of_double;
	}
	else if(t == CHAR)
	{
		insert->size = size_of_char;
		offset+=size_of_char;
	}
	else if( t== PTR)
	{
		insert->size=size_of_pointer;
		offset+=size_of_pointer;
	}
	else
	{
		insert->size=0;
		offset+=0;
	}
	symbol_table[temp_name]=insert;
	symbols.pb(insert);
	//cout << "after offset " << offset << endl << endl;

	
	return temp_name;
}

void sym_tab::print_symtab()
{
	printf("Name\t\tType\t\tInit_Val\t\tSize\t\tOffset\n");
	sym_tab_row *curr;
	for(int i=0;i<symbols.size();i++)
	{
		curr=symbols[i];
		cout << curr->name << "\t\t";
		if(curr->type.type==INT)
			cout << "int"; 
		else if(curr->type.type==DOUBLE)
			cout << "double";
		else if(curr->type.type==CHAR)
			cout << "char";
		else if(curr->type.type==FUNCTION)
			cout << "function";
		else if(curr->type.type==PTR)
		{
			if(curr->type.type2==INT)
				cout << "int"; 
			else if(curr->type.type2==DOUBLE)
				cout << "double";
			else if(curr->type.type2==CHAR)
				cout << "char";
			for(int i=0;i<curr->type.pointers;i++)
				cout << "*";
		}
		else if(curr->type.type==ARRAY)
		{
			if(curr->type.type2==INT)
				cout << "int"; 
			else if(curr->type.type2==DOUBLE)
				cout << "double";
			else if(curr->type.type2==CHAR)
				cout << "char";
			vector<int> dim = curr->type.dims;
			for(int i=0;i<dim.size();i++)
			{
				if(dim[i]==0)
					printf("[]");
				else
					printf("[%d]",dim[i]);
			}
			if(dim.size()==0)
				printf("[]");
		}
		cout << "\t\t" ;
		if(curr->init_val==NULL)
			cout << "null";
		else
		{
			if(curr->type.type==INT)
				cout << curr->init_val->a;
			else if(curr->type.type==CHAR)
				cout << curr->init_val->b;
			else if(curr->type.type==DOUBLE)
				cout << curr->init_val->c;
			else
				cout << "--";
		}
		cout << "\t\t" << curr->size << "\t\t" << curr->offset << "\n";
	}
}

list<int> makelist(int index)
{
    list<int> new_list;
    new_list.pb(index);
    return new_list;
}
list<int> merge(list<int> a, list<int> b)
{
    list<int> merged;
    merged.merge(a);
    merged.merge(b);
    return merged;
}


//varaibles used
string func_running="";
extern quad_array QUAD_LIST;
extern sym_tab gst;
extern sym_tab *GST;
extern vector<string> str_consts;
map<int,string> labels;
void quad_codes(quads q);
void STRINGS();
void GLOBAL();
void GENCODE();

void GLOBAL()
{
	for (std::vector<sym_tab_row*>::iterator it = gst.symbols.begin(); it != gst.symbols.end(); ++it)
	{
		if((*it)->type.type==INT && (*it)->name[0]!='t')
		{
			if((*it)->init_val==NULL)
			{
				cout << "\t.comm\t" << (*it)->name << ",4,4" << endl;	
			}
			else
			{
				cout << "\t.globl\t" << (*it)->name << endl;
				cout << "\t.data\n";
				cout << "\t.align\t4\n";
				cout << "\t.type\t" << (*it)->name << ", @object" << endl;
				cout << "\t.size\t" << (*it)->name << ", 4" << endl;
				cout << (*it)->name <<":\n";
				cout << "\t.long\t" << (*it)->init_val->a << endl;
			}

		}
		if((*it)->type.type==CHAR && (*it)->name[0]!='t')
		{
			if((*it)->init_val==NULL)
			{
				cout << "\t.comm\t" << (*it)->name << ",1,1" << endl;	
			}
			else
			{
				cout << "\t.globl\t" << (*it)->name << endl;
				cout << "\t.data\n";
				cout << "\t.type\t" << (*it)->name << ", @object" << endl;
				cout << "\t.size\t" << (*it)->name << ", 1" << endl;
				cout << (*it)->name <<":\n";
				int tempp=(*it)->init_val->b;
				cout << "\t.byte\t" << tempp << endl;
			}
			
		}
	}
}

void STRINGS()
{
	printf(".section\t.rodata\n");
	int num=0;
	for (std::vector<string>::iterator it = str_consts.begin(); it != str_consts.end(); ++it)
	{
		cout << ".LC" << num++ << ":\n";

		cout << "\t.string " <<  *it << endl;
	}
	
}
int label_count=0;
void set_labels()
{
	
	for (std::vector<quads>::iterator it = QUAD_LIST.list_of_quads.begin(); it != QUAD_LIST.list_of_quads.end(); ++it)
	{
		if(it->op>=GOTO_EQ && it->op<=IF_FALSE_GOTO || it->op == GOTO)
		{
			//cout << "printing goto " << it->res << "\n";
			int target;
			stringstream targ;
			targ << it->res;
			targ >> target;
			if(!labels.count(target))
			{
				string label_name;
				stringstream name;
				name << ".L" << label_count;
				label_count++;
				name >> label_name;
				labels[target]=label_name; 
			}
			it->res=labels[target];
		}
	}
}

void gen_prologue(int mem_bind)
{
	int space=(mem_bind/16 + 1)*16;
	cout << "\t.text\n";
	cout << "\t.globl\t" << func_running << "\n";
	cout << "\t.type\t" << func_running << ", @function\n";
	cout << func_running << ":\n";
	//cout << "\t.cfi_startproc\n";
	cout << "\tpushq\t%rbp\n";
	//ut << "\t.cfi_def_cfa_offset 16\n";
	//cout << "\t.cfi_offset 6, -16\n";
	cout << "\tmovq\t%rsp, %rbp\n";
	//cout << "\t.cfi_def_cfa_register 6\n";
	cout << "\tsubq\t$" << space << ", %rsp\n";
}

void gencode()
{
	GLOBAL();
	STRINGS();
	sym_tab_row *curr_func=NULL;
	sym_tab *curr_func_tab=NULL;
	set_labels();
	//cout << "\t.text\n";
	for(int i=0;i<QUAD_LIST.list_of_quads.size();i++)
	{
		
		cout << "# " ;
		QUAD_LIST.list_of_quads[i].print_quad();
		if(labels.count(i))
			cout << labels[i] << ":\n";
		if(QUAD_LIST.list_of_quads[i].op==FUNC_BEG)
		{
			i++;
			if(QUAD_LIST.list_of_quads[i].op==FUNC_END)
				continue;
			else
				i--;
			curr_func=gst.look_in_global(QUAD_LIST.list_of_quads[i].res);
			curr_func_tab=curr_func->nested_table;
			//ret val and return address at 0  and 4
			int taking_param=1,mem_bind=16;
			GST=curr_func_tab;
			for(int j=0;j<curr_func_tab->symbols.size();j++)
			{
				if(curr_func_tab->symbols[j]->name == "RETVAL")
				{
					taking_param=0;
					mem_bind=0;

					if(curr_func_tab->symbols.size()>j+1)
						mem_bind=-curr_func_tab->symbols[j+1]->size;
				}
				else
				{
					if(!taking_param)
					{
						curr_func_tab->symbols[j]->offset=mem_bind;
						if(curr_func_tab->symbols.size()>j+1)
							mem_bind-=curr_func_tab->symbols[j+1]->size;
					}
					else
					{
						curr_func_tab->symbols[j]->offset=mem_bind;
						mem_bind+=8;
					}

				}
				//cout << "name -> " << curr_func_tab->symbols[j]->name << " bind->" << curr_func_tab->symbols[j]->offset << " size ->" << curr_func_tab->symbols[j]->size <<"\n";
			}
			if(mem_bind>=0)
				mem_bind=0;
			else
				mem_bind=(-1)*mem_bind;
			func_running=QUAD_LIST.list_of_quads[i].res;
			gen_prologue(mem_bind);
		}
		else if(QUAD_LIST.list_of_quads[i].op==FUNC_END)
		{
			GST=&(gst);
			func_running="";
			cout << "\tleave\n";
			cout << "\tret\n";
			cout << "\t.size\t" << QUAD_LIST.list_of_quads[i].res << ", .-" << QUAD_LIST.list_of_quads[i].res << "\n";
		}

		if(func_running!="")
			quad_codes(QUAD_LIST.list_of_quads[i]);
	}
}

sym_tab_row* sym_tab::look_in_global(string var)
{
	if(symbol_table.count(var))
	{
		//printf("inside look in globa\n");
		//cout << var << endl;
		return symbol_table[var];
	}
	else
		return NULL;
}

stack<pair<string,int> > parameters;

void quad_codes(quads q)
{
	string have_label=q.res;
	bool has_str_label=false;
	if(q.res[0]=='.' && q.res[1]=='L' && q.res[2]=='C')
		has_str_label=true;
	string to_print1="",to_print2="",to_printres="";
	int off1=0,off2=0,offres=0;
	sym_tab_row *local1=GST->lookup(q.arg1);
	sym_tab_row *local2=GST->lookup(q.arg2);
	sym_tab_row *local3=GST->lookup(q.res);
	sym_tab_row *global1=gst.look_in_global(q.arg1);
	sym_tab_row *global2=gst.look_in_global(q.arg2);
	sym_tab_row *global3=gst.look_in_global(q.res);
	//printf("args\n");
	//cout << q.arg1 << "  " << q.res << endl;
	if(GST!=&gst)
	{
		//printf("here\n");

		if(global1==NULL)
		{
			off1=local1->offset;
		}
		if(global2==NULL)
			off2=local2->offset;
		if(global3==NULL)
			offres=local3->offset;
		if(q.arg1[0]>'9' || q.arg1[0]<'0')
		{
			if(global1==NULL)
			{
				stringstream conv;
				conv << off1;
				conv >> to_print1;
				to_print1=to_print1+"(%rbp)";
				//printf("print1\n");
				//cout << to_print1 << endl;
			}
			else
			{
				to_print1=q.arg1+"(%rip)";
			}
		}
		if(q.res[0]>'9' || q.res[0]<'0')
		{
			if(global3==NULL)
			{
				stringstream conv;
				conv << offres;
				conv >> to_printres;
				to_printres=to_printres+"(%rbp)";
				//printf("printres\n");
				//cout << to_printres << endl;
			}
			else
			{
				to_printres=q.res+"(%rip)";
			}
		}
		if(q.arg2[0]>'9' || q.arg2[0]<'0')
		{
			if(global2==NULL)
			{
				stringstream conv;
				conv << off2;
				conv >> to_print2;
				to_print2=to_print2+"(%rbp)";

			}
			else
			{
				to_print2=q.arg2+"(%rip)";
			}
		}

	}
	else
	{
		//printf("wrong\n");
		to_print1=q.arg1;
		to_print2=q.arg2;
		to_printres=q.res;
	}

	if(has_str_label)
		to_printres=have_label;

	if(q.op==ASSIGN)
	{
		if(q.res[0]!='t' || local3->type.type==INT || local3->type.type==PTR)
		{
			if(local3->type.type!=PTR)
			{
				if(q.arg1[0]<'0' || q.arg1[0]>'9')
				{
					cout << "\tmovl\t" << to_print1 << ", %eax" << endl;
					cout << "\tmovl\t%eax, " << to_printres << endl; 
				}
				else
				{
					cout << "\tmovl\t$" << q.arg1 << ", " << to_printres << endl;
				}
			}
			else
			{
				cout << "\tmovq\t" << to_print1 << ", %rax" << endl;
				cout << "\tmovq\t%rax, " << to_printres << endl; 
			}
		}
		else
		{
			int temp=q.arg1[0];
			cout << "\tmovb\t$" << temp << ", " << to_printres << endl;
		}
	}
	else if(q.op==U_MINUS)
	{
		cout << "\tmovl\t" << to_print1 << ", %eax\n";
		cout << "\tnegl\t%eax\n";
		cout << "\tmovl\t%eax, " << to_printres << "\n"; 
	}
	else if(q.op==ADD)
	{
		if(q.arg1[0]>'0' && q.arg1[0]<='9')
		{
			cout << "\tmovl\t$" << q.arg1 << ", %eax\n";
		}
		else
		{
			cout << "\tmovl\t" << to_print1 << ", %eax\n"; 
		}
		if(q.arg2[0]>'0' && q.arg2[0]<='9')
		{
			cout << "\tmovl\t$" << q.arg2 << ", %edx\n";
		}
		else
		{
			cout << "\tmovl\t" << to_print2 << ", %edx\n"; 
		}
		cout << "\taddl\t%edx, %eax\n";
		cout << "\tmovl\t%eax, " << to_printres << endl;

	}
	else if(q.op==SUB)
	{
		if(q.arg1[0]>'0' && q.arg1[0]<='9')
		{
			cout << "\tmovl\t$" << q.arg1 << ", %edx\n";
		}
		else
		{
			cout << "\tmovl\t" << to_print1 << ", %edx\n"; 
		}
		if(q.arg2[0]>'0' && q.arg2[0]<='9')
		{
			cout << "\tmovl\t$" << q.arg2 << ", %eax\n";
		}
		else
		{
			cout << "\tmovl\t" << to_print2 << ", %eax\n"; 
		}
		cout << "\tsubl\t%eax, %edx\n";
		cout << "\tmovl\t%edx, %eax\n";
		cout << "\tmovl\t%eax, " << to_printres << endl;
	}
	else if(q.op==MULT)
	{
		if(q.arg1[0]>'0' && q.arg1[0]<='9')
		{
			cout << "\tmovl\t$" << q.arg1 << ", %eax\n";
		}
		else
		{
			cout << "\tmovl\t" << to_print1 << ", %eax\n"; 
		}
		/*if(q.arg2[0]>'0' && q.arg2[0]<='9')
		{
			cout << "\tmovl\t$" << q.arg2 << ", %edx\n";
		}
		else
		{
			cout << "\tmovl\t" << to_print2 << ", %edx\n"; 
		}*/
		cout << "\timull\t";
		if(q.arg2[0]>'0' && q.arg2[0]<='9')
		{
			cout << "$" << q.arg2 << ", %eax\n";
		}
		else
		{
			cout << to_print2 << ", %eax\n";
		}
		cout << "\tmovl\t%eax, " << to_printres << endl;
	}
	else if(q.op==DIV)
	{
		cout << "\tmovl\t" << to_print1 << ", %eax\n";
		cout << "\tcltd\n\tidivl\t" << to_print2 << endl;
		cout << "\tmovl\t%eax, " << to_printres << endl;
	}
	else if(q.op==MOD)
	{
		cout << "\tmovl\t" << to_print1 << ", %eax\n";
		cout << "\tcltd\n\tidivl\t" << to_print2 << endl;
		cout << "\tmovl\t%edx, " << to_printres << endl;
	}
	else if(q.op==GOTO)
	{
		cout << "\tjmp\t" << q.res << endl;
	}
	else if(q.op==GOTO_LT)
	{
		cout << "\tmovl\t" << to_print1 << ", %eax\n";
		cout << "\tcmpl\t" << to_print2 << ", %eax\n";
		cout << "\tjge\t.L" << label_count << "\n";
		cout << "\tjmp\t" << q.res << endl;
		cout << ".L" << label_count++ << ":\n";
	}
	else if(q.op==GOTO_GT)
	{
		cout << "\tmovl\t" << to_print1 << ", %eax\n";
		cout << "\tcmpl\t" << to_print2 << ", %eax\n";
		cout << "\tjle\t.L" << label_count << "\n";
		cout << "\tjmp\t" << q.res << endl;
		cout << ".L" << label_count++ << ":\n";
	}
	else if(q.op==GOTO_GTE)
	{
		cout << "\tmovl\t" << to_print1 << ", %eax\n";
		cout << "\tcmpl\t" << to_print2 << ", %eax\n";
		cout << "\tjl\t.L" << label_count << "\n";
		cout << "\tjmp\t" << q.res << endl;
		cout << ".L" << label_count++ << ":\n";
	}
	else if(q.op==GOTO_LTE)
	{
		cout << "\tmovl\t" << to_print1 << ", %eax\n";
		cout << "\tcmpl\t" << to_print2 << ", %eax\n";
		cout << "\tjg\t.L" << label_count << "\n";
		cout << "\tjmp\t" << q.res << endl;
		cout << ".L" << label_count++ << ":\n";
	}
	else if(q.op==GOTO_GTE)
	{
		cout << "\tmovl\t" << to_print1 << ", %eax\n";
		cout << "\tcmpl\t" << to_print2 << ", %eax\n";
		cout << "\tjl\t.L" << label_count << "\n";
		cout << "\tjmp\t" << q.res << endl;
		cout << ".L" << label_count++ << ":\n";
	}
	else if(q.op==GOTO_EQ)
	{
		cout << "\tmovl\t" << to_print1 << ", %eax\n";
		if(q.arg2[0]>='0' && q.arg2[0]<='9')
			cout << "\tcmpl\t$" << q.arg2 << ", %eax\n";
		else
			cout << "\tcmpl\t" << to_print2 << ", %eax\n";
		cout << "\tjne\t.L" << label_count << "\n";
		cout << "\tjmp\t" << q.res << endl;
		cout << ".L" << label_count++ << ":\n";
	}
	else if(q.op==GOTO_NEQ)
	{
		cout << "\tmovl\t" << to_print1 << ", %eax\n";
		cout << "\tcmpl\t" << to_print2 << ", %eax\n";
		cout << "\tje\t.L" << label_count << "\n";
		cout << "\tjmp\t" << q.res << endl;
		cout << ".L" << label_count++ << ":\n";
	}
	else if(q.op==IF_GOTO)
	{
		cout << "\tmovl\t" << to_print1 << ", %eax\n";
		cout << "\tcmpl\t$0" << ", %eax\n";
		cout << "\tje\t.L" << label_count << "\n";
		cout << "\tjmp\t" << q.res << endl;
		cout << ".L" << label_count++ << ":\n";
	}
	else if(q.op==IF_FALSE_GOTO)
	{
		cout << "\tmovl\t" << to_print1 << ", %eax\n";
		cout << "\tcmpl\t$0" << ", %eax\n";
		cout << "\tjne\t.L" << label_count << "\n";
		cout << "\tjmp\t" << q.res << endl;
		cout << ".L" << label_count++ << ":\n";
	}
	else if(q.op==ARR_IDX_ARG)
	{
		
		cout<<"\tmovl\t"<<to_print2<<", %edx\n";
		cout<<"cltq\n";
		if(off1<0)
		{
				cout<<"\tmovl\t"<<off1<<"(%rbp,%rdx,1), %eax\n";
				cout<<"\tmovl\t%eax, "<<to_printres<<"\n";
		}
		else
		{
			cout<<"\tmovq\t"<<off1<<"(%rbp), %rdi\n";
			cout<<"\taddq\t%rdi, %rdx\n";
			cout<<"\tmovq\t(%rdx) ,%rax\n";
			cout<<"\tmovq\t%rax, "<<to_printres<<endl;
		}
	}
	else if(q.op==ARR_IDX_RES)
	{
		cout<<"\tmovl\t"<<to_print2<<", %edx\n";
		cout<<"\tmovl\t"<<to_print1<<", %eax\n";
		cout<<"cltq\n";
		if(offres>0)
		{
			cout<<"\tmovq\t"<<offres<<"(%rbp), %rdi\n";
			cout<<"\taddq\t%rdi, %rdx\n";
			cout<<"\tmovl\t%eax, (%rdx)\n";
		}
		else
		{
			cout<<"\tmovl\t%eax, "<<offres<<"(%rbp,%rdx,1)\n";
		}
	}
	else if(q.op==REFERENCE)
	{
		if(off1<0)
		{
			cout << "\tleaq\t" << to_print1 << ", %rax\n";
			cout << "\tmovq\t%rax, " << to_printres << endl;
		}
		else
		{
			cout << "\tmovq\t" << to_print1 << ", %rax\n";
			cout << "\tmovq\t%rax, " << to_printres << endl;
		}
	}
	else if(q.op==DEREFERENCE)
	{
		cout << "\tmovq\t" << to_print1 << ", %rax\n";
		cout << "\tmovq\t(%rax), %rdx\n";
		cout << "\tmovq\t%rdx, " << to_printres << endl;
	}
	else if(q.op==L_DEREF)
	{
		cout << "\tmovq\t" << to_printres << ", %rdx\n";
		cout << "\tmovl\t" << to_print1 << ", %eax\n";
		cout << "\tmovl\t%eax, (%rdx)\n";
		//cout << "\tmovl\t%eax, " << to_printres <<"\n";
	}
	else if(q.op==PARAM)
	{
		int size_of_param;
		if(global3==NULL)
		{
			if(local3->type.type==INT)
				size_of_param=size_of_int;
			else if(local3->type.type==CHAR)
				size_of_param=size_of_char;
			else
				size_of_param=size_of_pointer;
		}
		else
		{
			if(global3->type.type==INT)
				size_of_param=size_of_int;
			else if(global3->type.type==CHAR)
				size_of_param=size_of_char;
			else
				size_of_param=size_of_pointer;
		}
		stringstream one;
		if(q.res[0]=='.')
		{
			one << "\tmovq\t$" << to_printres << ", %rax\n";
		}
		else if(q.res[0]>='0' && q.res[0]<='9')
		{
			one << "\tmovq\t$" << q.res << ", %rax\n";
		}
		else
		{
			if(local3->type.type!=ARRAY)
			{
				if(local3->type.type!=PTR)
				{
					one << "\tmovq\t" << to_printres << ", %rax\n";
				}
				else
				{
					if(local3==NULL)
					{
						one << "\tleaq\t" << to_printres << ", %rax\n";
					}
					else
					{
						one << "\tmovq\t" << to_printres << ", %rax\n";
					}
				}
			}
			else
			{
				if(offres<0)
					one << "\tleaq\t" << to_printres << ", %rax\n";
				else
				{
					one<<"\tmovq\t"<<offres<<"(%rbp), %rdi\n";
					one << "\tmovq\t%rdi, %rax\n";
				}
			}
		}
		parameters.push(make_pair(one.str(),size_of_param));
	}
	else if(q.op==CALL)
	{
		int num_of_params;
		stringstream conv;
		conv << q.arg1;
		conv >> num_of_params;
		int total_size=0;
		int k=0;
		
		if(num_of_params>6)
		{
			for(int i=0;i<num_of_params-6;i++)
			{
				string s=parameters.top().first;
				cout << s;
				cout << "\tpushq\t%rax\n";
				total_size+=parameters.top().second;
				parameters.pop();
			}
			cout << parameters.top().first << "\tpushq\t%rax\n" << "\tmovq\t%rax, %r9d\n";
			total_size+=parameters.top().second;
			parameters.pop();
			cout << parameters.top().first << "\tpushq\t%rax\n" << "\tmovq\t%rax, %r8d\n";
			total_size+=parameters.top().second;				
			parameters.pop();
			cout << parameters.top().first << "\tpushq\t%rax\n" << "\tmovq\t%rax, %rcx\n";
			total_size+=parameters.top().second;
			parameters.pop();
			cout << parameters.top().first << "\tpushq\t%rax\n" << "\tmovq\t%rax, %rdx\n";
			total_size+=parameters.top().second;
			parameters.pop();
			cout << parameters.top().first << "\tpushq\t%rax\n" << "\tmovq\t%rax, %rsi\n";
			total_size+=parameters.top().second;
			parameters.pop();
			cout << parameters.top().first << "\tpushq\t%rax\n" << "\tmovq\t%rax, %rdi\n";
			total_size+=parameters.top().second;
			parameters.pop();

		}
		else
		{
			while(!parameters.empty())
			{
				if(parameters.size()==6)
				{
					cout << parameters.top().first << "\tpushq\t%rax\n" << "\tmovq\t%rax, %r9d\n";
					total_size+=parameters.top().second;
					parameters.pop();
				}
				else if(parameters.size()==5)
				{
					cout << parameters.top().first << "\tpushq\t%rax\n" << "\tmovq\t%rax, %r8d\n";
					total_size+=parameters.top().second;
					parameters.pop();
				}
				else if(parameters.size()==4)
				{
					cout << parameters.top().first << "\tpushq\t%rax\n" << "\tmovq\t%rax, %rcx\n";
					total_size+=parameters.top().second;
					parameters.pop();
				}
				else if(parameters.size()==3)
				{
					cout << parameters.top().first << "\tpushq\t%rax\n" << "\tmovq\t%rax, %rdx\n";
					total_size+=parameters.top().second;
					parameters.pop();
				}
				else if(parameters.size()==2)
				{
					cout << parameters.top().first << "\tpushq\t%rax\n" << "\tmovq\t%rax, %rsi\n";
					total_size+=parameters.top().second;
					parameters.pop();
				}
				else if(parameters.size()==1)
				{
					cout << parameters.top().first << "\tpushq\t%rax\n" << "\tmovq\t%rax, %rdi\n";
					total_size+=parameters.top().second;
					parameters.pop();
				}
			}
		}
		cout << "\tcall\t" << q.res <<"\n";
		if(q.arg2!= "")
			cout << "\tmovq\t%rax, " << to_print2 << endl;
		cout << "\taddq\t$" << total_size << ", %rsp\n";
	}
	else if(q.op==RETURN)
	{
		if(q.res!="")
		{
			cout << "\tmovq\t" << to_printres << ", %rax\n";
		}
		cout << "\tleave\n";
		cout << "\tret\n";
	}
}

