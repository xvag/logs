%{
#include <stdio.h>
#include <math.h>
#define RED "\x1B[31m"
#define BLU "\x1B[34m"
#define GRN "\x1B[32m"
#define YEL "\x1B[33m"
#define MAG "\x1B[35m"
#define CYN "\x1B[36m"
#define RESET "\x1B[0m"

int lcounter=1, counter=0, space=0;
%}

EXP [eE]
SIGN [+-]
DIGIT [0-9]
NOZERO [1-9]
LOW [a-z]
CAP [A-Z]
VAR [a-zA-Z_][a-zA-Z_0-9]*
OP "+"|"-"|"*"|"/"|"%"|"="|"+="|"-="|"*="|"/="|"%="|"**"|"//"|"**="|"//="
KEPT "int"|"float"|"str"|"len"|"type"|"input"|"print"
SPECIAL ";"|","|"("|")"|"["|"]"|"{"|"}"
ALL .

%%

{OP} {
printf(CYN"Operator"RESET"(line %d): %s\n",lcounter, yytext);}

{KEPT} {
printf("Kept(line %d): %s\n",lcounter, yytext);}

{SPECIAL} {
printf("Special(line %d): %s\n",lcounter, yytext);}

{SIGN}?(0|{NOZERO}{DIGIT}*) {
printf(BLU"Integer"RESET"(line %d): %s (%d)\n",lcounter, yytext, atoi(yytext));}

{SIGN}?({DIGIT}+"."{DIGIT}*|"."{DIGIT}+)({EXP}{SIGN}?{DIGIT}+)? {
printf(BLU"Float"RESET"(line %d): %s (%g)\n",lcounter, yytext, atof(yytext));}

{SIGN}?\.{EXP}?{SIGN}?{DIGIT}* {
printf(RED"Error: Illegal Float"RESET"(line:%d): %s\n",lcounter,yytext);};

"\"".*"\""|"'".*"'" {
printf(GRN"String"RESET"(line %d): %s\n",lcounter, yytext); }

("\""[^\"\n]*)|("'"[^'\n]*) {
printf(RED"Error: Illegal String"RESET"(line:%d): %s\n", lcounter, yytext);}

{VAR} {
printf(MAG"Variable"RESET"(line %d): %s\n", lcounter, yytext);}

{DIGIT}+{VAR} {
printf(RED"Error: Illegal Variable name"RESET"(line:%d): %s\n", lcounter, yytext);}

"#".*|"\""{3}[\xA\x20-\x7E]*"\""{3} {
printf(YEL"Comment"RESET"(line %d): %s\n", lcounter, yytext);}


\n { lcounter++; }
" " { space++; }
. { counter++; }
%%

int main(int argc, char **argv){
	if(argc==3){
		if(!(yyin=fopen(argv[1],"r"))){
			fprintf(stderr, "Can't read file: %s\n", argv[1]);
			return 1;
		}
		if(!(yyout=fopen(argv[2],"w"))){
			fprintf(stderr, "Cannot create file: %s\n", argv[2]);
			return 1;
		}
	}
	else if(argc==2){
		if(!(yyin=fopen(argv[1],"r"))){
			fprintf(stderr, "Can't read file: %s\n", argv[1]);
			return 1;
		}
	}

	yylex();
	printf("# of lines = %d\n", lcounter);
	printf("# of spaces = %d\n", space);
	printf("# of unscanned characters = %d\n", counter);

}
