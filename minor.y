%{
#include <stdio.h>
#include "lex.yy.c"
%}

%union {
	int i;
	char *s;
	int array;
	Node *n;
};

%token <i> INTEGER
%token <s> STRING VARIABLE
%token <array> ARRAY
%token PROGRAM MODULE START END VOID CONST NUMBER ARRAY STRING FUNCTION PUBLIC FORWARD IF ELSE ELIF
%token FI FOR UNTILL STEP DO DONE REPEAT STOP RETURN

%%

start: { ECHO; }
;

%%

