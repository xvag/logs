%{
#define RED "\x1B[31m"
#define BLU "\x1B[34m"
#define GRN "\x1B[32m"
#define YEL "\x1B[33m"
#define MAG "\x1B[35m"
#define CYN "\x1B[36m"
#define RESET "\x1B[0m"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#define YYSTYPE char

int errorflag=0;
int ge=0, be=0;

extern char * yytext;
void yyerror(char const* s);
extern FILE *yyin;
extern int yylineno;
extern int yylex();
%}

/* tokens */

%error-verbose
%token NEWLINE ASSIGN_OP DECL_TYPE POW FDIV
%token LEN TYPE INPUT PRINT
%token VAR STRING INT FLOAT


/* priorities */

%left '(' ')'
%left '+' '-'
%left '*' '/' '%' FDIV
%right POW

%start program

%%
program: 
	| program codeline
	;

codeline: NEWLINE {printf("\n");}
	| decl NEWLINE {printf("\n ### line[%d] "GRN"OK"RESET" ###\n\n", yylineno-1); ge++;}
	| assign NEWLINE {printf("\n ### line[%d] "GRN"OK"RESET" ###\n\n", yylineno-1); ge++;}
	| print NEWLINE {printf("\n ### line[%d] "GRN"OK"RESET" ###\n\n", yylineno-1); ge++;}
	| error NEWLINE {errorflag=1; yyerrok; be++;}
	;

decl: DECL_TYPE decl_var {printf("\n Declaration");}
	| DECL_TYPE VAR '=' expr {printf("\n Declaration with assignment");}
	;

decl_var: VAR
	| VAR ',' decl_var
	;

assign: VAR '=' expr {printf("\n Assignment");}
	| VAR '=' list {printf("\n List creation");}
	| VAR ASSIGN_OP expr {printf("\n Expression Assignment");}
	| VAR '=' func {printf("\n Function with Assignment");}
	| VAR '[' INT ']' '=' expr {printf("\n Assignment to list element");}
	| VAR '[' INT ']' ASSIGN_OP expr {printf("\n Expression assignment to list element");}
	| VAR '[' INT ']' '=' func  {printf("\n Function with assignment to list element");}
	;

expr: element
	| VAR '[' INT ']'
	| '(' expr ')'
	| expr '+' expr {printf("\n Addition (%d + %d)", $1, $3);}
	| expr '-' expr {printf("\n Substraction (%d - %d)", $1, $3);}
	| expr '*' expr {printf("\n Multiplication (%d * %d)", $1, $3);}
	| expr '/' expr {printf("\n Division (%d / %d)", $1, $3);
			if($3==0){printf(RED"\nWarning!"RESET" Division with zero.");} }
	| expr '%' expr {printf("\n Remainder (%d %% %d)", $1, $3);
			if($3==0){printf(RED"\nWarning!"RESET" Division with zero.");} }
	| expr POW expr {printf("\n Power (%d ^ %d)", $1, $3);}
	| expr FDIV expr {printf("\n Floor Division (%d // %d)", $1, $3);}
	;

list: '[' list_elements ']'

list_elements: element
	| element ',' list_elements
	;

element: VAR
	| INT {$$ = atoi(yytext);}
	| FLOAT {$$ = atof(yytext);}
	| STRING
	;

func: LEN '(' VAR ')' {printf("\n Function len()");}
	| TYPE '(' VAR ')' {printf("\n Function type()");}
	| INPUT '(' ')' {printf("\n Function input()");}
	| INPUT '(' STRING ')' {printf("\n Function input()");}
	;

print:	PRINT '(' STRING ')' {printf("\n Function print()");}
%%


void yyerror(const char* msg)
{
	printf(RED"\nLine: %d FAILURE %s\n\n"RESET,yylineno,msg);
}


int main(int argc,char **argv)
{
	if(argc == 2)
		yyin=fopen(argv[1],"r");
	else
		yyin=stdin; 

	if (yyparse()== 0 && errorflag == 0) {
		printf(" Good expressions # = %d\n Bad expressions # = %d\n", ge, be);
		fprintf(stderr, GRN"Successful parsing.\n"RESET);
	} else {
		printf(" Good expressions # = %d\n Bad expressions # = %d\n", ge, be);
		fprintf(stderr, RED"error(s) found!\n"RESET);
	}

  return 0;
}
