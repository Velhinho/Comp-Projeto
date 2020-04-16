%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "node.h"
#include "tabid.h"

int yylex();
void evaluate(Node *p);
void yyerror(char *s);
int lbl;
%}

%union {
	int i;
	char *s;
	int array;
	Node *n;
};

%token <i> INTEGER
%token <s> STRING ID
%token <array> ARRAY
%token PROGRAM MODULE START END VOID CONST NUMBER ARRAY STRING FUNCTION PUBLIC FORWARD IF THEN ELSE
%token ELIF FI FOR UNTIL STEP DO DONE REPEAT STOP RETURN

%right ASG
%left '|'
%left '&'
%nonassoc '~'
%left EQ NE
%left '>' '<' GE LE 
%left '+' '-'
%left '*' '/' '%'
%right '^'
%nonassoc UMINUS LOC '?'
%nonassoc '(' ')' '[' ']'


%%

file: ;

%%


char *mklbl(int n) {
  static char buf[20];
  sprintf(buf, "_i%d", n);
  return strdup(buf);
}

char **yynames =
#if YYDEBUG > 0
		 (char**)yyname;
#else
		 0;
#endif
