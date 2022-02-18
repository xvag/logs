%option noyywrap

%{
#define RED "\x1B[31m"
#define BLU "\x1B[34m"
#define GRN "\x1B[32m"
#define YEL "\x1B[33m"
#define MAG "\x1B[35m"
#define CYN "\x1B[36m"
#define RESET "\x1B[0m"

#define YYSTYPE double

#include "bison.tab.h"  

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int counter=0;

int gw=0, bw=0;
%}

/* Declarations */

EXP [eE]
SIGN [+-]
DIGIT [0-9]
NOZERO [1-9]
LOW [a-z]
CAP [A-Z]
VAR [a-zA-Z_][a-zA-Z_0-9]*
ASSIGN_OP "+="|"-="|"*="|"/="|"%="|"**="|"//="
DECL_TYPE "int"|"float"|"str"
ALL .


/* Rules */

%%

"#".*|"\""{3}[\xA\x20-\x7E]*"\""{3} { }

"len" {printf("%s", yytext); gw++; return LEN;}
"type" {printf("%s", yytext); gw++; return TYPE;}
"input" {printf("%s", yytext); gw++; return INPUT;}
"print" {printf("%s", yytext); gw++; return PRINT;}

[\[\](),=+\-*/%] {printf("%s",yytext); return *yytext;}

"**" {printf("%s", yytext); return POW;}
"//" {printf("%s", yytext); return FDIV;}

{ASSIGN_OP} {printf("%s", yytext);return ASSIGN_OP;}

{DECL_TYPE} {printf("%s", yytext); gw++; return DECL_TYPE;}

{SIGN}?(0|{NOZERO}{DIGIT}*) {printf("%s",yytext); gw++; return INT;}

{SIGN}?({DIGIT}+"."{DIGIT}*|"."{DIGIT}+)({EXP}{SIGN}?{DIGIT}+)? {
printf("%s",yytext);
gw++;
return FLOAT;}

{VAR} {printf("%s", yytext); gw++; return VAR;}

"\"".*"\""|"'".*"'" {printf("%s", yytext); gw++; return STRING; }

("\""[^\"\n]*)|("'"[^'\n]*) {
printf(RED"\n Lexical Error: Illegal String"RESET"(line:%d): %s", yylineno, yytext);
bw++;}

{SIGN}?\.{EXP}?{SIGN}?{DIGIT}* {
printf(RED"\n Lexical Error: Illegal Float"RESET"(line:%d): %s",yylineno,yytext);
bw++;};

{DIGIT}+{VAR} {
printf(RED"\n Lexical Error: Illegal Variable name"RESET"(line:%d): %s", yylineno, yytext);
bw++;}

\n { yylineno++; return NEWLINE; }
" " {printf("%s", yytext);}

<<EOF>>	{ printf("\n Good Words # = %d\n Bad Words # = %d\n",gw, bw); return 0; };

. { counter++; /* counts unscanned characters */ }

%%
