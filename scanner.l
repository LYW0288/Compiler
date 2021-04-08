%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"

int	lineCount=0;
char lineContext[300], str[100];
int isSource=1, isToken=1;
%}

%x	COMMENT
%x	STRING
%x	CHAR
/*exclusive*/

%%
\n					{lineCount++;}
<COMMENT>\n			{lineCount++;
					strcpy(lineContext, "");}
[\b\t\f\r\v ]		{strcat(lineContext, yytext);}
'					{BEGIN CHAR;}
<CHAR>[^\'\\]		{strcpy(yylval.sym, yytext); return CHAR_;}
<CHAR>\\n			{strcpy(yylval.sym, "\n"); return CHAR_;}
<CHAR>\\t			{strcpy(yylval.sym, "\t"); return CHAR_;}
<CHAR>\\\'			{strcpy(yylval.sym, "\'"); return CHAR_;}
<CHAR>\\\\			{strcpy(yylval.sym, "\\"); return CHAR_;}
<CHAR>\'			{BEGIN 0;}
\"					{BEGIN STRING;}
<STRING>[^\"\\]+	{strcpy(yylval.sym, yytext); return STRING_;}
<STRING>\\\"?		{strcpy(yylval.sym, yytext); return STRING_;}
<STRING>\"			{BEGIN 0;}
\/\*				{ BEGIN COMMENT;}
<COMMENT>[^(\*)\n]+	{}
<COMMENT>\*\/		{ BEGIN 0;}
\/\/[^\n]* 			{}
void				{ strcpy(yylval.sym, yytext); return VOID_; }
const				{ strcpy(yylval.sym, yytext); return CONST_; }
NULL				{strcat(lineContext, yytext);}
for					{strcpy(yylval.sym, yytext); return FOR_;}
do					{ strcpy(yylval.sym, yytext); return DO_; }
while				{ strcpy(yylval.sym, yytext); return WHILE_; }
break				{strcpy(yylval.sym, yytext); return BREAK_;}
continue			{strcpy(yylval.sym, yytext); return CONTINUE_;}
if					{strcpy(yylval.sym, yytext); return IF_;}
else				{strcpy(yylval.sym, yytext); return ELSE_;}
return				{strcpy(yylval.sym, yytext); return RETURN_;}
struct				{strcat(lineContext, yytext);}
switch				{strcpy(yylval.sym, yytext); return SWITCH_;}
case				{strcpy(yylval.sym, yytext); return CASE_;}
default				{strcpy(yylval.sym, yytext); return DEFAULT_;}

fclose				{strcat(lineContext, yytext);}
clearerr			{strcat(lineContext, yytext);}
feof				{strcat(lineContext, yytext);}
ferror				{strcat(lineContext, yytext);}
fflush				{strcat(lineContext, yytext);}
fgetpos				{strcat(lineContext, yytext);}
fopen				{strcat(lineContext, yytext);}
fread				{strcat(lineContext, yytext);}
freopen				{strcat(lineContext, yytext);}
fseek				{strcat(lineContext, yytext);}
fsetpos				{strcat(lineContext, yytext);}
ftell				{strcat(lineContext, yytext);}
fwrite				{strcat(lineContext, yytext);}
remove				{strcat(lineContext, yytext);}
rename				{strcat(lineContext, yytext);}
rewind				{strcat(lineContext, yytext);}
setbuf				{strcat(lineContext, yytext);}
setvbuf				{strcat(lineContext, yytext);}
tmpfile				{strcat(lineContext, yytext);}
tmpnam				{strcat(lineContext, yytext);}
fprintf				{strcat(lineContext, yytext);}
printf				{strcat(lineContext, yytext);}
sprintf				{strcat(lineContext, yytext);}
vfprintf			{strcat(lineContext, yytext);}
vprintf				{strcat(lineContext, yytext);}
vsprintf			{strcat(lineContext, yytext);}
fscanf				{strcat(lineContext, yytext);}
scanf				{strcat(lineContext, yytext);}
sscanf				{strcat(lineContext, yytext);}
fgetc				{strcat(lineContext, yytext);}
fgets				{strcat(lineContext, yytext);}
fputc				{strcat(lineContext, yytext);}
fputs				{strcat(lineContext, yytext);}
getc				{strcat(lineContext, yytext);}
getchar				{strcat(lineContext, yytext);}
gets				{strcat(lineContext, yytext);}
putc				{strcat(lineContext, yytext);}
putchar				{strcat(lineContext, yytext);}
puts				{strcat(lineContext, yytext);}
ungetc				{strcat(lineContext, yytext);}
perror				{strcat(lineContext, yytext);}
int					{ strcpy(yylval.sym, yytext); return TYPE; }
double				{ strcpy(yylval.sym, yytext); return TYPE; }
float				{ strcpy(yylval.sym, yytext); return TYPE; }
char				{ strcpy(yylval.sym, yytext); return TYPE; }
[[:alpha:]_][[:alnum:]_]*		{ strcpy(yylval.sym, yytext); return VARIABLE; }
\+					{ return '+'; }
-					{ return '-'; }
\*					{ return '*'; }
\/					{ return '/'; }
%					{ return '%'; }
\+\+				{ strcpy(yylval.sym, yytext); return IDCRE; }
--					{ strcpy(yylval.sym, yytext); return IDCRE; }
\<					{ return '<'; }
\<=					{ strcpy(yylval.sym, yytext); return CONTRAST; }
>					{ return '>'; }
>=					{ strcpy(yylval.sym, yytext); return CONTRAST; }
==					{ strcpy(yylval.sym, yytext); return EQUAL; }
!=					{ strcpy(yylval.sym, yytext); return EQUAL; }
=					{ return '='; }
&&					{ strcpy(yylval.sym, yytext); return AND; }
\|\|				{ strcpy(yylval.sym, yytext); return OR; }
!					{ return '!'; }
&					{ return '&'; }
\|					{ return '|'; }
:					{ return ':'; }
;					{ return ';'; }
,					{ return ','; }
\.					{ return '.'; }
\?					{ return '?'; }
\[					{ return '['; }
]					{ return ']'; }
\(					{ return '('; }
\)					{ return ')'; }
\{					{ return '{'; }
\}					{ return '}'; }
[[:digit:]]+					{ strcpy(yylval.sym, yytext); return NUM; }
[[:digit:]]*\.[[:digit:]]+	{ strcpy(yylval.sym, yytext); return DOUBLE; }

%%