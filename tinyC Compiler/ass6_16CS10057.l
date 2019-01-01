%{
#include "ass6_16CS10057_translator.h"
#include <stdio.h>

#include "y.tab.h"
%}	
AUTO						"auto"
ENUM 						"enum"
RESTRICT 					"restrict"
UNSIGNED					"unsigned"
BREAK						"break"
EXTERN						"extern"		
RETURN 						"return"
VOID						"void"
CASE						"case"
FLOAT						"float"
SHORT						"short"
VOLATILE					"volatile"
CHAR 						"char"
FOR							"for"
SIGNED						"signed"
WHILE						"while"
CONST						"const"
GOTO						"goto"
SIZEOF						"sizeof"
_BOOL						"_bool"
CONTINUE					"continue"
IF							"if"
STATIC						"static"
_COMPLEX					"complex"
DEFAULT						"default"
INLINE						"inline"
STRUCT						"struct"
_IMAGINARY					"_imaginary"
DO							"do"
INT							"int"
SWITCH						"switch"
DOUBLE						"double"
LONG						"long"
TYPEDEF						"typedef"
ELSE						"else"
REGISTER					"register"
UNION						"union"

MULTI_LINE_COMMENT			"/"\*(([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*)\*+"/"
SINGLE_LINE_COMMENT			"//".*
WS [ \n\t]
ID 							[_A-Za-z][_A-Za-z0-9]*
INTEGER_CONST				([1-9][0-9]*)|"0"
FLOAT_CONST					[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?
ENUMERATOR					[_A-Za-z][_A-Za-z0-9]*
CHAR_CONST					\'(([^\'\\\n]|[\\a\\b\\f\\n\\r\\t\\v\\\'\\\"\\?\\\\])+)\'
STRING 						\"(([^\'\\\n]|[\\a\\b\\f\\n\\r\\t\\v\\\'\\\"\\?\\\\])*)\"

COMMENT 			{SINGLE_LINE_COMMENT}|{MULTI_LINE_COMMENT} 

%%

	
{AUTO}						{return AUTO_KEY;}
{ENUM}						{return ENUM_KEY;}
{RESTRICT}					{return RESTRICT_KEY;}
{UNSIGNED}					{return UNSIGNED_KEY;}
{BREAK}						{return BREAK_KEY;}
{EXTERN}					{return EXTERN_KEY;}
{RETURN}					{return RETURN_KEY;}
{VOID}						{return VOID_KEY;}
{CASE}						{return CASE_KEY;}
{FLOAT}						{return FLOAT_KEY;}
{SHORT}						{return SHORT_KEY;}
{VOLATILE}					{return VOLATILE_KEY;}
{CHAR}						{return CHAR_KEY;}
{FOR}						{return FOR_KEY;}
{SIGNED}					{return SIGNED_KEY;}
{WHILE}						{return WHILE_KEY;}
{CONST}						{return CONST_KEY;}
{GOTO}						{return GOTO_KEY;}
{SIZEOF}					{return SIZEOF_KEY;}
{_BOOL}						{return BOOL_KEY;}
{CONTINUE}					{return CONTINUE_KEY;}
{IF}						{return IF_KEY;}
{STATIC}					{return STATIC_KEY;}
{_COMPLEX}					{return COMPLEX_KEY;}
{DEFAULT}					{return DEFAULT_KEY;}
{INLINE}					{return INLINE_KEY;}
{STRUCT}					{return STRUCT_KEY;}
{_IMAGINARY}				{return IMAGINARY_KEY;}
{DO}						{return DO_KEY;}
{INT}						{return INT_KEY;}
{SWITCH}					{return SWITCH_KEY;}
{DOUBLE}					{return DOUBLE_KEY;}
{LONG}						{return LONG_KEY;}
{TYPEDEF}					{return TYPEDEF_KEY;}
{ELSE}						{return ELSE_KEY;}
{REGISTER}					{return REGISTER_KEY;}
{UNION}						{return UNION_KEY;}

"<<="						{return LEFT_SHIFT_EQUAL;}
"..."						{return ELLIPSES;}
">>="						{return RIGHT_SHIFT_EQUAL;}
"->"						{return VAL_AT;}
"++"						{return PLUS_PLUS;}
"--"						{return MINUS_MINUS;}
"<<"						{return LEFT_SHIFT;}
">>"						{return RIGHT_SHIFT;}
"<="						{return LESS_THAN_EQUAL;}
">="						{return GREATER_THAN_EQUAL;}
"=="						{return EQUAL_EQUAL;}
"!="						{return NOT_EQUAL;}
"&&"						{return LOGICAL_AND;}
"||"						{return LOGICAL_OR;}
"*="						{return MULTIPLY_EQUAL;}
"/="						{return DIVIDE_EQUAL;}
"%="						{return MODULO_EQUAL;}
"+="						{return PLUS_EQUAL;}
"-="						{return MINUS_EQUAL;}
"&="						{return AND_EQUAL;}
"^="						{return BITWISENOT_EQUAL;}
"|="						{return OR_EQUAL;}
";"                     { return ';'; }
"{"                     { return '{'; }
"}"                     { return '}'; }
","                     { return ','; }
":"                     { return ':'; }
"="                     { return '='; }
"("                     { return '('; }
")"                     { return ')'; }
"["                     { return '['; }
"]"                     { return ']'; }
"."                     { return '.'; }
"&"                     { return '&'; }
"!"                     { return '!'; }
"~"                     { return '~'; }
"-"                     { return '-'; }
"+"                     { return '+'; }
"*"                     { return '*'; }
"/"                     { return '/'; }
"%"                     { return '%'; }
"<"                     { return '<'; }
">"                     { return '>'; }
"^"                     { return '^'; }
"|"                     { return '|'; }
"?"                     { return '?'; }
"#"                     { return '#'; }

{COMMENT}	{;}
{ID}                    { yylval.str = new string(yytext); return IDENTIFIER;}
{INTEGER_CONST}             { yylval.ival = atoi(yytext); return INTEGER_CONST;}
{FLOAT_CONST}           { yylval.dval = atof(yytext); return FLOAT_CONST;}
{CHAR_CONST}          { yylval.cval = yytext[1]; return CHAR_CONST;}
{STRING}        { yylval.str = new string(yytext); return STRING_LITERAL;}


{WS}        {;}

%%
