%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "code.h"

extern FILE *f_asm;
int yylex();
int	lineNo=0;
FILE *f_asm;
char curLine[300];
char gtmp[10][300];
int cur_mode = GLOBAL_MODE;
int if_scope[10]={0};
int wh_scope[10]={0};
char cur_func[300];
int para_count = 0;
int arg_now = 0;
int local_now = 0;
int eq_id = 0;
%}

%union{
	char sym[2500];
}
%token <sym> CONST_
%token <sym> NUM
%token <sym> DOUBLE
%token <sym> STRING_
%token <sym> CHAR_
%token <sym> VARIABLE
%token <sym> CONTRAST
%token <sym> EQUAL
%token <sym> IDCRE
//%token <sym> UMINUS
//%token <sym> SUFFIX
%token <sym> OR
%token <sym> AND
%token <sym> TYPE
%token <sym> VOID_
%token <sym> IF_
%token <sym> ELSE_
%token <sym> SWITCH_
%token <sym> DEFAULT_
%token <sym> CASE_
%token <sym> WHILE_
%token <sym> DO_
%token <sym> FOR_
%token <sym> RETURN_
%token <sym> BREAK_
%token <sym> CONTINUE_

%token <sym> LOWER
%token <sym> HIGHER

%start start
//EXPR
%type <sym> expr
%type <sym> or_expr
%type <sym> and_expr
%type <sym> oro_expr
%type <sym> ando_expr
%type <sym> eq_expr
%type <sym> con_expr
%type <sym> add_expr
%type <sym> term_expr
%type <sym> umi_expr
%type <sym> conp_expr
%type <sym> trans_expr
%type <sym> terminal
%type <sym> array
%type <sym> var
%type <sym> string_
//
%type <sym> func
//SCALAR
%type <sym> scalar
%type <sym> ident
//ARRAY DELC
%type <sym> array_decl
%type <sym> identArr
%type <sym> arr_list
%type <sym> arr_content
%type <sym> arr
%type <sym> sub_id
//CONST
%type <sym> const_decl
%type <sym> const_id
%type <sym> const_sub
//FUNCTION DECL
	//decl
%type <sym> func_decl
%type <sym> parameters
%type <sym> sub_func
	//def
%type <sym> func_def
%type <sym> compound_stmt
%type <sym> sub_comp
%type <sym> subsub_com
//INT DOUBLE
%type <sym> int_literal
%type <sym> double_literal
////
%type <sym> global
/////STATEMENT
%type <sym> stmt
%type <sym> sub_return
	//if
%type <sym> ifstmt
%type <sym> subif
	//switch
%type <sym> switch_stmt
%type <sym> switch_clauses
%type <sym> sub_switch
%type <sym> subsub_switch
	//while
%type <sym> while_stmt
	//for
%type <sym> for_stmt
%type <sym> sub_for



%nonassoc LOWER
%right '=' 		
%left OR
%left AND 
%left '|' 
%left '&'
%left EQUAL
%left '<' '>' CONTRAST
%left '+' '-'
%left '*' '/' '%'
%right IDCRE '!'
%left '[' ']' '(' ')'
%nonassoc HIGHER



%%

start: global { };
global: global scalar {strcpy($$, $1); strcat($$, $2);}
	  | global array_decl {strcpy($$, $1); strcat($$, $2);}
	  | global const_decl {strcpy($$, $1); strcat($$, $2);}
	  | global func_decl {strcpy($$, $1); strcat($$, $2);}
	  | global func_def{strcpy($$, $1); strcat($$, $2);}
	  | /*nothing*/ {strcpy($$, "");};

//statement
stmt: expr ';' { strcpy($$, "<stmt>"); strcat($$, $1); strcat($$, ";"); strcat($$, "</stmt>");}
	| ifstmt { strcpy($$, "<stmt>"); strcat($$, $1); strcat($$, "</stmt>");}
	| switch_stmt { strcpy($$, "<stmt>"); strcat($$, $1); strcat($$, "</stmt>");}
	| while_stmt { strcpy($$, "<stmt>"); strcat($$, $1); strcat($$, "</stmt>");}
	| for_stmt { strcpy($$, "<stmt>"); strcat($$, $1); strcat($$, "</stmt>");}
	| RETURN_ sub_return ';' {
		fprintf(f_asm, "  lw t3, 0(sp)\n");
		fprintf(f_asm, "  addi sp, sp, 4\n");
		fprintf(f_asm, "  mv a0, t3\n");
	}
	| BREAK_ ';'{ strcpy($$, "<stmt>"); strcat($$, $1); strcat($$, ";");  strcat($$, "</stmt>");}
	| CONTINUE_ ';'{ strcpy($$, "<stmt>"); strcat($$, $1); strcat($$, ";");  strcat($$, "</stmt>");}
	| compound_stmt { strcpy($$, "<stmt>"); strcat($$, $1);  strcat($$, "</stmt>");};
sub_return: expr | /*nothing*/{strcpy($$, "");};
////if
ifstmt: IF_ '(' expr ')' 
		{
			cur_scope++;
			fprintf(f_asm, "  lw t0, 0(sp)\n");
			fprintf(f_asm, "  addi sp, sp, 4\n");
			fprintf(f_asm, "  beq t0, zero, if%d_%d\n",cur_scope, if_scope[cur_scope]);
		} compound_stmt subif {
			fprintf(f_asm, "if%d_%d:\n", cur_scope, if_scope[cur_scope]++);
			pop_up_symbol(cur_scope);
			cur_scope--;};
subif: ELSE_ {
			fprintf(f_asm, "  jal zero, if%d_%d\n", cur_scope, if_scope[cur_scope]+1);
			fprintf(f_asm, "if%d_%d:\n", cur_scope, if_scope[cur_scope]++);
		} compound_stmt { }
		| /*npthing*/{strcpy($$, "");};
////switch
switch_stmt: SWITCH_ '(' expr ')' '{' switch_clauses '}'{
	strcpy($$, $1); strcat($$, "("); strcat($$, $3);  strcat($$, ")");  
	strcat($$, "{"); strcat($$, $6);  strcat($$, "}");  
	};
switch_clauses: switch_clauses sub_switch {strcpy($$, $1); strcat($$, $2); }
		  	 | /*nothing*/ {strcpy($$, "");};
sub_switch: CASE_ int_literal ':'subsub_switch{strcpy($$, $1); strcat($$, $2);strcat($$, ":"); strcat($$, $4);}
		  | DEFAULT_  ':' subsub_switch {strcpy($$, $1); strcat($$, ":"); strcat($$, $3);};
subsub_switch: subsub_switch stmt {strcpy($$, $1); strcat($$, $2);}
			 | /*nothing*/ {strcpy($$, "");};
////while stmt
while_stmt: WHILE_ {
				cur_scope++;
				fprintf(f_asm, "wh%d_%d:\n", cur_scope, wh_scope[cur_scope]++);
			} '(' expr ')' {
				fprintf(f_asm, "  lw t0, 0(sp)\n");	
				fprintf(f_asm, "  addi sp, sp, 4\n");
				fprintf(f_asm, "  beq t0, zero, wh%d_%d\n", cur_scope, wh_scope[cur_scope]);
			} stmt {
				pop_up_symbol(cur_scope);
				fprintf(f_asm, "  jal zero, wh%d_%d\n", cur_scope, wh_scope[cur_scope]-1);
				fprintf(f_asm, "wh%d_%d:\n", cur_scope, wh_scope[cur_scope]++);
				cur_scope--;
			}
			| DO_ {
				cur_scope++;
				fprintf(f_asm, "wh%d_%d:\n", cur_scope, wh_scope[cur_scope]++);
			} stmt WHILE_ '(' expr ')' ';'{
				pop_up_symbol(cur_scope);
				fprintf(f_asm, "  lw t0, 0(sp)\n");	
				fprintf(f_asm, "  addi sp, sp, 4\n");
				fprintf(f_asm, "  bne t0, zero, wh%d_%d\n", cur_scope, wh_scope[cur_scope]-1);
				cur_scope--;
			};
////FOR
for_stmt: FOR_ '(' sub_for ';' sub_for ';' sub_for ')' stmt{
		  strcpy($$, $1); strcat($$, "("); strcat($$, $3);  strcat($$, ";");
		  strcat($$, $5); strcat($$, ";"); strcat($$, $7);  strcat($$, ")");  		
		  strcat($$, $9);};
sub_for: expr | /*nothing*/ {strcpy($$, "");};
/////////////////////////////////////////////////
//SCALAR && ARRAY
scalar: TYPE ident ';' {strcpy($$, "<scalar_decl>"); strcat($$, $1); strcat($$, $2); strcat($$, ";"); strcat($$, "</scalar_decl>");};
ident: ident ',' VARIABLE {strcpy($$, $1); strcat($$, ","); strcat($$, $3);}
	 | ident '=' expr { 
		if(cur_mode==LOCAL_MODE){ }
	 }
	 | VARIABLE {
	 	install_symbol($1, cur_mode);
	 };
//ARR
array_decl: TYPE identArr ';' {strcpy($$, "<array_decl>"); strcat($$, $1); strcat($$, $2); strcat($$, ";"); strcat($$, "</array_decl>");};
identArr: identArr ',' sub_id {strcpy($$, $1); strcat($$, ","); strcat($$, $3);}
	 | identArr '=' arr_content {strcpy($$, $1); strcat($$, "="); strcat($$, $3);}
	 | sub_id { strcpy($$, $1); };
arr_content: '{' arr_list '}' {strcpy($$, "{");strcat($$, $2); strcat($$, "}");}
		   | expr{strcpy($$, $1);};
arr_list: arr_content {strcpy($$, $1);}
		| arr_list ',' arr_content {strcpy($$, $1);strcat($$, ","); strcat($$, $3);};

sub_id: VARIABLE arr {strcpy($$, $1);  strcat($$, $2);};
arr: arr '[' int_literal ']' {strcpy($$, $1); strcat($$, "["); strcat($$, $3); strcat($$, "]");}
	 | '[' int_literal ']' {strcpy($$, "["); strcat($$, $2); strcat($$, "]");};
//CONST
const_decl: CONST_ TYPE const_id ';' {strcpy($$, "<const_decl>"); strcat($$, $1); strcat($$, $2);  strcat($$, $3); strcat($$, ";"); strcat($$, "</const_decl>");};
const_id: const_id ',' const_sub {strcpy($$, $1); strcat($$, ","); strcat($$, $3);}
	 | const_sub {strcpy($$, $1);};
const_sub: VARIABLE '=' expr {strcpy($$, $1); strcat($$, "="); strcat($$, $3);};
//FUNCTOPN DECL
func_decl: VOID_ VARIABLE '(' parameters ')' ';'  {
			fprintf(f_asm, ".global %s\n", $2);}
		 | TYPE VARIABLE '(' parameters ')' ';' {
		 	fprintf(f_asm, ".global %s\n", $2);
		 };
parameters: parameters ',' sub_func {strcpy($$, $1); strcat($$, ","); strcat($$, $3);}
		  | sub_func {strcpy($$, $1);}
		  |/*nothing*/{strcpy($$, "");};
sub_func: TYPE VARIABLE {
		sprintf(gtmp[para_count++],"%s",$2);
		strcpy($$,$2);
	};
//FUNCTION DEF
func_def: VOID_ VARIABLE '(' parameters ')' {
		cur_scope++;
		install_symbol($2,cur_mode);
		cur_mode = LOCAL_MODE;
		code_gen_func_header($2);
		strcpy(cur_func ,$2);
		for(int i = 0; i < para_count; i++)
		{
			install_symbol(gtmp[i],cur_mode);
			fprintf(f_asm, "  addi sp, sp, -4\n");
			fprintf(f_asm, "  sw a%d, 0(sp)\n",i);
		}
		para_count = 0;
		local_now = 0;
		
	}  compound_stmt  {
		pop_up_symbol(cur_scope);
		cur_scope--;
		code_gen_end($2);
		cur_mode = GLOBAL_MODE;
		strcpy($$,$2);
	}
	| TYPE VARIABLE '(' parameters ')'  {
		cur_scope++;
		install_symbol($2,cur_mode);
		cur_mode = LOCAL_MODE;
		code_gen_func_header($2);
		strcpy(cur_func ,$2);
		for(int i = 0; i < para_count; i++)
		{
			install_symbol(gtmp[i],cur_mode);
			fprintf(f_asm, "  addi sp, sp, -4\n");
			fprintf(f_asm, "  sw a%d, 0(sp)\n",i);
		}
		para_count = 0;
		local_now = 0;
		
	}  compound_stmt  {
		pop_up_symbol(cur_scope);
		cur_scope--;
		code_gen_end($2);
		cur_mode = GLOBAL_MODE;
		strcpy($$,$2);
	};
compound_stmt: '{' sub_comp '}' {};
sub_comp: sub_comp subsub_com {strcpy($$, $1); strcat($$, $2);}
		| /*nothing*/ {strcpy($$, "");};
subsub_com: scalar | array_decl | const_decl | stmt;
///////////////////////////
//EXPRESSION
expr: VARIABLE '=' expr  {
		fprintf(f_asm, "  lw t0, 0(sp)\n");	
		fprintf(f_asm, "  addi sp, sp, 4\n");
	 	int index = look_up_symbol($1);
		fprintf(f_asm, "  sw t0, %d(s0)\n", table[index].offset*-4 -48);
	}| or_expr;
or_expr: or_expr OR and_expr {
			fprintf(f_asm, "  lw t1, 0(sp)\n");	
			fprintf(f_asm, "  addi sp, sp, 4\n");
			fprintf(f_asm, "  lw t0, 0(sp)\n");	
			fprintf(f_asm, "  addi sp, sp, 4\n");
			fprintf(f_asm, "  bne t0, zero, eq%d_0\n",eq_id);
			fprintf(f_asm, "  bne t1, zero, eq%d_0\n",eq_id);
			fprintf(f_asm, "  li t0, 0\n");
			fprintf(f_asm, "  jal zero, eq%d_1\n",eq_id);
			fprintf(f_asm, "eq%d_0:\n",eq_id);
			fprintf(f_asm, "  li t0, 1\n");
			fprintf(f_asm, "eq%d_1:\n",eq_id++);
			fprintf(f_asm, "  addi sp, sp, -4\n");
			fprintf(f_asm, "  sw t0, 0(sp)\n");}
	   | and_expr;
and_expr: and_expr AND oro_expr {
			fprintf(f_asm, "  lw t1, 0(sp)\n");	
			fprintf(f_asm, "  addi sp, sp, 4\n");
			fprintf(f_asm, "  lw t0, 0(sp)\n");	
			fprintf(f_asm, "  addi sp, sp, 4\n");
			fprintf(f_asm, "  beq t0, zero, eq%d_0\n",eq_id);
			fprintf(f_asm, "  bne t0, t1, eq%d_0\n",eq_id);
			fprintf(f_asm, "  li t0, 1\n");
			fprintf(f_asm, "  jal zero, eq%d_1\n",eq_id);
			fprintf(f_asm, "eq%d_0:\n",eq_id);
			fprintf(f_asm, "  li t0, 0\n");
			fprintf(f_asm, "eq%d_1:\n",eq_id++);
			fprintf(f_asm, "  addi sp, sp, -4\n");
			fprintf(f_asm, "  sw t0, 0(sp)\n");}
		| oro_expr;
oro_expr: oro_expr '|' ando_expr {strcpy($$, "<expr>"); strcat($$, $1); strcat($$, "|"); strcat($$, $3); strcat($$, "</expr>");}
		| ando_expr;
ando_expr: ando_expr '&' eq_expr {strcpy($$, "<expr>"); strcat($$, $1); strcat($$, "&"); strcat($$, $3); strcat($$, "</expr>");}
		 | eq_expr;
eq_expr: eq_expr EQUAL con_expr {
		fprintf(f_asm, "  lw t1, 0(sp)\n");
		fprintf(f_asm, "  addi sp, sp, 4\n");
		fprintf(f_asm, "  lw t0, 0(sp)\n");	
		fprintf(f_asm, "  addi sp, sp, 4\n");
		if(strcmp($2, "==")==0)
			fprintf(f_asm, "  beq t0, t1, eq%d_0\n",eq_id);
		else 
			fprintf(f_asm, "  bne t0, t1, eq%d_0\n",eq_id);
		fprintf(f_asm, "  li t0, 0\n");
		fprintf(f_asm, "  jal zero, eq%d_1\n",eq_id);
		fprintf(f_asm, "eq%d_0:\n",eq_id);
		fprintf(f_asm, "  li t0, 1\n");
		fprintf(f_asm, "eq%d_1:\n",eq_id++);
		fprintf(f_asm, "  addi sp, sp, -4\n");
		fprintf(f_asm, "  sw t0, 0(sp)\n");}
	   | con_expr;
con_expr: con_expr CONTRAST add_expr {
			fprintf(f_asm, "  lw t1, 0(sp)\n");
			fprintf(f_asm, "  addi sp, sp, 4\n");
			fprintf(f_asm, "  lw t0, 0(sp)\n");	
			fprintf(f_asm, "  addi sp, sp, 4\n");
			if (strcmp($2, ">=")==0)
				fprintf(f_asm, "  bge t0, t1, eq%d_0\n",eq_id);
			else
				fprintf(f_asm, "  bge t1, t0, eq%d_0\n",eq_id);
			fprintf(f_asm, "  li t0, 0\n");
			fprintf(f_asm, "  jal zero, eq%d_1\n",eq_id);
			fprintf(f_asm, "eq%d_0:\n",eq_id);
			fprintf(f_asm, "  li t0, 1\n");
			fprintf(f_asm, "eq%d_1:\n",eq_id++);
			fprintf(f_asm, "  addi sp, sp, -4\n");
			fprintf(f_asm, "  sw t0, 0(sp)\n");
		}
		| con_expr '>' add_expr {
			fprintf(f_asm, "  lw t1, 0(sp)\n");
			fprintf(f_asm, "  addi sp, sp, 4\n");
			fprintf(f_asm, "  lw t0, 0(sp)\n");	
			fprintf(f_asm, "  addi sp, sp, 4\n");
			fprintf(f_asm, "  blt t1, t0, eq%d_0\n",eq_id);
			fprintf(f_asm, "  li t0, 0\n");
			fprintf(f_asm, "  jal zero, eq%d_1\n",eq_id);
			fprintf(f_asm, "eq%d_0:\n",eq_id);
			fprintf(f_asm, "  li t0, 1\n");
			fprintf(f_asm, "eq%d_1:\n",eq_id++);
			fprintf(f_asm, "  addi sp, sp, -4\n");
			fprintf(f_asm, "  sw t0, 0(sp)\n");
		}
		| con_expr '<' add_expr {
			fprintf(f_asm, "  lw t1, 0(sp)\n");
			fprintf(f_asm, "  addi sp, sp, 4\n");
			fprintf(f_asm, "  lw t0, 0(sp)\n");	
			fprintf(f_asm, "  addi sp, sp, 4\n");
			fprintf(f_asm, "  blt t0, t1, eq%d_0\n",eq_id);
			fprintf(f_asm, "  li t0, 0\n");
			fprintf(f_asm, "  jal zero, eq%d_1\n",eq_id);
			fprintf(f_asm, "eq%d_0:\n",eq_id);
			fprintf(f_asm, "  li t0, 1\n");
			fprintf(f_asm, "eq%d_1:\n",eq_id++);
			fprintf(f_asm, "  addi sp, sp, -4\n");
			fprintf(f_asm, "  sw t0, 0(sp)\n");
		}
	    | add_expr;
add_expr: add_expr '+' term_expr {
		fprintf(f_asm, "  lw t1, 0(sp)\n");
		fprintf(f_asm, "  addi sp, sp, 4\n");
		fprintf(f_asm, "  lw t0, 0(sp)\n");
		fprintf(f_asm, "  addi sp, sp, 4\n");
		fprintf(f_asm, "  add t0, t0, t1\n");
		fprintf(f_asm, "  sw t0, -4(sp)\n");
		fprintf(f_asm, "  addi sp, sp, -4\n");
	}
		| add_expr '-' term_expr {
		fprintf(f_asm, "  lw t1, 0(sp)\n");
		fprintf(f_asm, "  addi sp, sp, 4\n");
		fprintf(f_asm, "  lw t0, 0(sp)\n");
		fprintf(f_asm, "  addi sp, sp, 4\n");
		fprintf(f_asm, "  sub t0, t0, t1\n");
		fprintf(f_asm, "  sw t0, -4(sp)\n");
		fprintf(f_asm, "  addi sp, sp, -4\n");
	}
		| term_expr  { strcpy($$, $1); };
term_expr: term_expr '*' umi_expr  {
		fprintf(f_asm, "  lw t1, 0(sp)\n");
		fprintf(f_asm, "  addi sp, sp, 4\n");
		fprintf(f_asm, "  lw t0, 0(sp)\n");
		fprintf(f_asm, "  addi sp, sp, 4\n");
		fprintf(f_asm, "  mul t0, t0, t1\n");
		fprintf(f_asm, "  sw t0, -4(sp)\n");
		fprintf(f_asm, "  addi sp, sp, -4\n");
	}
		 | term_expr '/' umi_expr {
		fprintf(f_asm, "  lw t1, 0(sp)\n");
		fprintf(f_asm, "  addi sp, sp, 4\n");
		fprintf(f_asm, "  lw t0, 0(sp)\n");
		fprintf(f_asm, "  addi sp, sp, 4\n");
		fprintf(f_asm, "  div t0, t0, t1\n");
		fprintf(f_asm, "  sw t0, -4(sp)\n");
		fprintf(f_asm, "  addi sp, sp, -4\n");
	}
		 | term_expr '%' umi_expr {
		fprintf(f_asm, "  lw t1, 0(sp)\n");
		fprintf(f_asm, "  addi sp, sp, 4\n");
		fprintf(f_asm, "  lw t0, 0(sp)\n");
		fprintf(f_asm, "  addi sp, sp, 4\n");
		fprintf(f_asm, "  rem t0, t0, t1\n");
		fprintf(f_asm, "  sw t0, -4(sp)\n");
		fprintf(f_asm, "  addi sp, sp, -4\n");
	}
		 | umi_expr  { strcpy($$, $1); };
umi_expr: '+' umi_expr  {strcpy($$, "<expr>"); strcat($$, "+"); strcat($$, $2); strcat($$, "</expr>");}
		| '-' umi_expr  {
			fprintf(f_asm, "  lw t0, 0(sp)\n");
			fprintf(f_asm, "  addi sp, sp, 4\n");
			fprintf(f_asm, "  not t0, t0\n");
			fprintf(f_asm, "  addi sp, sp, -4\n");
			fprintf(f_asm, "  sw t0, 0(sp)\n");}
		| IDCRE var {
			fprintf(f_asm, "  lw t0, 0(sp)\n");
			fprintf(f_asm, "  addi sp, sp, 4\n");
			fprintf(f_asm, "  li t1, 1\n");
			if(strcmp($1, "--")==0) 
				fprintf(f_asm, "  sub t0, t0, t1\n");
			else if(strcmp($1, "++")==0) 
				fprintf(f_asm, "  add t0, t0, t1\n");
		 	int index = look_up_symbol($2);
			fprintf(f_asm, "  sw t0, %d(s0)\n", table[index].offset*-4 -48);
			fprintf(f_asm, "  addi sp, sp, -4\n");
			fprintf(f_asm, "  sw t0, 0(sp)\n");
		}
		| '!'umi_expr {strcpy($$, "<expr>"); strcat($$, "!"); strcat($$, $2); strcat($$, "</expr>");}
	    | conp_expr;
conp_expr: '[' expr ']' {strcpy($$, "<expr>"); strcat($$, "["); strcat($$, $2); strcat($$, "]"); strcat($$, "</expr>");}
		 | '(' expr ')' {strcpy($$, "<expr>"); strcat($$, "("); strcat($$, $2); strcat($$, ")"); strcat($$, "</expr>");}
	     | terminal;
terminal: NUM { strcpy($$, $1);
			fprintf(f_asm,  "  li t0, %s\n", $1);
			fprintf(f_asm,  "  sw t0, -4(sp)\n");
			fprintf(f_asm,  "  addi sp, sp, -4\n");
		}
		| var IDCRE %prec HIGHER {
			fprintf(f_asm, "  lw t0, 0(sp)\n");
			fprintf(f_asm, "  lw t3, 0(sp)\n");
			fprintf(f_asm, "  addi sp, sp, 4\n");
			fprintf(f_asm, "  li t1, 1\n");
			if(strcmp($2, "--")==0) 
				fprintf(f_asm, "  sub t0, t0, t1\n");
			else if(strcmp($2, "++")==0) 
				fprintf(f_asm, "  add t0, t0, t1\n");
		 	int index = look_up_symbol($1);
			fprintf(f_asm, "  sw t0, %d(s0)\n", table[index].offset*-4 -48);
			fprintf(f_asm, "  addi sp, sp, -4\n");
			fprintf(f_asm, "  sw t3, 0(sp)\n");
		}
   		| VARIABLE '(' { arg_now = 0; } func ')' { 
   			for(int i = 0; i < arg_now; i++){
				fprintf(f_asm,  "  lw a%d, 0(sp)\n", arg_now - i -1);	
				fprintf(f_asm,  "  addi sp, sp, 4\n");
			}	
			fprintf(f_asm,  "  sw ra, -4(sp)\n");
			fprintf(f_asm,  "  addi sp, sp, -4\n");
			fprintf(f_asm,  "  jal ra, %s\n", $1);
			fprintf(f_asm,  "  lw ra, 0(sp)\n");
			fprintf(f_asm,  "  addi sp, sp, 4\n");
		}
   		| VARIABLE '(' ')'  { 	
			fprintf(f_asm,  "  sw ra, -4(sp)\n");
			fprintf(f_asm,  "  addi sp, sp, -4\n");
			fprintf(f_asm,  "  jal ra, %s\n", $1);
			fprintf(f_asm,  "  lw ra, 0(sp)\n");
			fprintf(f_asm,  "  addi sp, sp, 4\n");
		}
		| var %prec LOWER { strcpy($$, "<expr>"); strcat($$, $1); strcat($$, "</expr>"); }
		| string_  { strcpy($$, "<expr>");strcat($$, "\""); strcat($$, $1); strcat($$, "\""); strcat($$, "</expr>"); }
		| CHAR_  { strcpy($$, "<expr>");strcat($$, $1); strcat($$, "</expr>"); }
		| double_literal { strcpy($$, "<expr>"); strcat($$, $1); strcat($$, "</expr>"); };
var: VARIABLE trans_expr {
			if(cur_mode==LOCAL_MODE){
			 	int index = look_up_symbol($1);
			 	fprintf(f_asm, "  lw t0, %d(s0)\n", table[index].offset*-4 -48);
			 	fprintf(f_asm, "  sw t0, -4(sp)\n");
			 	fprintf(f_asm, "  addi sp, sp, -4\n");
		 	}
	 	};
string_: string_ STRING_ { strcpy($$, $1); strcat($$, $2);}
   	   | STRING_  { strcpy($$, $1); };
trans_expr: array { strcpy($$, $1);}
   		  |/*nothing*/ { strcpy($$, ""); };
func: func ',' expr {
			arg_now++;
		}
		| expr {
			arg_now++;
		};
array: array '[' expr ']' {strcpy($$, $1); strcat($$, "["); strcat($$, $3); strcat($$, "]");}
	 | '[' expr ']' {strcpy($$, "["); strcat($$, $2); strcat($$, "]");};
/////////////////////////////////////////////////


//INT AND DOUBLE
int_literal: '+' NUM { char tmp[40]; sprintf(tmp, "%d", atoi($2)); strcpy($$, tmp); }
		   | '-' NUM { char tmp[40]; sprintf(tmp, "%d", -atoi($2)); strcpy($$, tmp); }
		   | NUM {char tmp[40]; sprintf(tmp, "%d", atoi($1)); strcpy($$, tmp);};
double_literal: DOUBLE {char tmp[40]; sprintf(tmp, "%f", atof($1)); strcpy($$, tmp);};



%%
int main(void) {
	if ((f_asm = fopen("codegen.S", "w")) == NULL) 
	{
		fprintf(stderr, "File Open Error\n");
		exit(1);
	}
	
	if (yyparse())
		fprintf(stderr,"Error\n");
	else
		fprintf(stdout,"Success\n"); 
	
	
	fclose(f_asm);
	return 0;
}

void yyerror(char * msg) {
	fprintf(stderr, "Error at line %d: %s\n", lineNo, curLine);
	exit(1);
}
