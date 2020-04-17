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
%token <s> STRING CHAR ID
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

/* FALTA MODULE */
file: program   {evaluate($1); free($1);}
;

program: PROGRAM declarations START body END
    | PROGRAM START body END
    | PROGRAM START END
;

body: variables
    | instructions
    | variables instructions
;

instructions: instruction | instructions instruction
;

instruction: ifInstruction
;

ifInstruction: ifExpr FI
    | ifExpr elifList FI
    | ifExpr elifList elseExpr FI
    | ifExpr elseExpr FI
;

ifExpr: IF expr THEN
    | IF expr THEN instructions
;

elifList: elifExpr | elifExpr elifList
;

elifExpr: ELIF expr THEN
    | ELIF expr THEN instructions
;

elseExpr: ELSE
    | ELSE instructions
;

expr: ID
	| literals
	| '[' INTEGER ']'
	| '-' expr %prec UMINUS
	| expr '+' expr
	| expr '-' expr
	| expr '*' expr
	| expr '/' expr
	| expr '%' expr
	| expr '^' expr
	| expr '<' expr
	| expr '>' expr
	| expr GE expr
	| expr LE expr
	| expr NE expr
	| expr EQ expr
	| '(' expr ')'
	| '?' expr
	| '&' expr
	;

declarations: declaration 
    | declaration ';' declarations
;

declaration: function 
    | qualifier CONST variableDeclaration
    | qualifier variableDeclaration
    | CONST variableDeclaration
;

function: FUNCTION qualifier type ID variables DONE 
    | FUNCTION qualifier type ID variables DO body
    | FUNCTION qualifier VOID ID variables DONE
    | FUNCTION qualifier VOID ID variables DO body
    | FUNCTION type ID variables DONE
    | FUNCTION type ID variables DO body
    | FUNCTION VOID ID variables DONE
    | FUNCTION VOID ID variables DO body
    | FUNCTION qualifier type ID DONE
    | FUNCTION qualifier type ID DO body
    | FUNCTION qualifier VOID ID DONE
    | FUNCTION qualifier VOID ID DO body
    | FUNCTION type ID DONE
    | FUNCTION type ID DO body
    | FUNCTION VOID ID DONE
    | FUNCTION VOID ID DO body
;

qualifier: PUBLIC | FORWARD
;

type: NUMBER | STRING | ARRAY
;

variables: variable | variable  %prec ';' variables
;

variable: type ID
    | type ID '[' INTEGER ']'
;

variableDeclaration: variable
    | variable ASG literals
;

literals: literal
    | literal literals
    | literal ',' literals
;

literal: INTEGER | STRING | CHAR
;

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
