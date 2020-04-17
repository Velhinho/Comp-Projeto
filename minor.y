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

%type <n> expr literals literal declarations declaration
%type <n> qualifier variableDeclaration variable type
%%

/* FALTA MODULE */
file: program
;

program: PROGRAM declarations START body END
    | PROGRAM START body END
    | PROGRAM START END
;

body: variables
    | instructions
    | variables instructions
;

instructions: instruction       
    | instructions instruction
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

expr: ID                      { if (IDfind($1, 0) < 0) $$ = 0; else $$ = strNode(ID, $1); }
	| literals                { $$ = $1; }
	| '-' expr %prec UMINUS   { $$ = uniNode(UMINUS, $2); }
	| expr '+' expr			  { $$ = binNode('+', $1, $3); }
	| expr '-' expr			  { $$ = binNode('-', $1, $3); }
	| expr '*' expr			  { $$ = binNode('*', $1, $3); }
	| expr '/' expr			  { $$ = binNode('/', $1, $3); }
	| expr '%' expr			  { $$ = binNode('%', $1, $3); }
	| expr '<' expr			  { $$ = binNode('<', $1, $3); }
	| expr '>' expr			  { $$ = binNode('>', $1, $3); }
	| expr GE expr			  { $$ = binNode(GE, $1, $3); }
	| expr LE expr			  { $$ = binNode(LE, $1, $3); }
	| expr NE expr			  { $$ = binNode(NE, $1, $3); }
	| expr EQ expr			  { $$ = binNode(EQ, $1, $3); }
	;

declarations: declaration { $$ = $1; }
    | declaration ';' declarations { $$ = binNode(';', $1, $3); }
;

declaration: qualifier CONST variableDeclaration   { $$ = binNode(CONST, $1, $3); }
    | qualifier variableDeclaration         { $$ = binNode(0, $1, $2); }
    | CONST variableDeclaration             { $$ = uniNode(CONST, $2); }
;

/*
function: FUNCTION qualifier type ID variables DONE     { $$ = pentaNode()}
    | FUNCTION qualifier type ID variables DO body      {}
    | FUNCTION qualifier VOID ID variables DONE         {}
    | FUNCTION qualifier VOID ID variables DO body      {}
    | FUNCTION type ID variables DONE                   {}
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
*/
qualifier: PUBLIC   { $$ = nilNode(PUBLIC); }
    | FORWARD       { $$ = nilNode(FORWARD); }
;

type: NUMBER        { $$ = nilNode(NUMBER); }
    | STRING        { $$ = nilNode(STRING); }
    | ARRAY         { $$ = nilNode(ARRAY); }
;

variables: variable 
    | variable  %prec ';' variables
;

variable: type ID               { IDnew($1->attrib, $2, (void*)IDtest); }
    | type ID '[' INTEGER ']'   { IDnew($1->attrib, $2, (void*)IDtest); }
;

variableDeclaration: variable   { $$ = $1; }
    | variable ASG literals     { $$ = binNode(ASG, $1, $3); }
;

literals: literal           { $$ = $1; }
    | literal ',' literals  { $$ = binNode(',', $1, $3); }
;

literal: INTEGER    { $$ = intNode(INTEGER, $1); }
    | STRING        { $$ = strNode(STRING, $1); }
    | CHAR          { $$ = strNode(STRING, $1); }
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
