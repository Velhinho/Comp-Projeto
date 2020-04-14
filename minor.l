%{
#include "y.tab.h"
char *dupstr(const char *s);
extern void yyerror(const char *msg);
%}


/* Regular Definitions */
whiteSpace [ \n\r\t]+
anyChar .|\n
singleComment "$$"
multiCommentInit "$"
multiCommentFinal "$"
letter [a-zA-Z]
digit [0-9]
underscore "_"
id {letter}({letter}|{digit}|{underscore})*
number {digit}+(\.{digit}+)?(E[+-]?{digit}+)?


%%

 /* 2.1 white space */
{whiteSpace}    {/* ignore */}


 /* 2.2 Comments */
{singleComment} {/* ignore */}
{multiCommentInit}{anyChar}+{multiCommentFinal} {/* ignore */}


 /* 2.3 Identifiers */
{id}            {yylval.s = dupstr(yytext); return VARIABLE}


 /* 2.4 Keywords */
program         {return PROGRAM;}
module          {return MODULE;}
start           {return START;}
end             {return END;}
void            {return VOID;}
const           {return CONST;}
number          {return NUMBER;}
array           {return ARRAY;}
string          {return STRING;}
function        {return FUNCTION;}
public          {return PUBLIC;}
forward         {return FORWARD;}
if              {return IF;}
else            {return ELSE;}
elif            {return ELIF;}
fi              {return FI;}
for             {return FOR;}
until           {return UNTIL;}
step            {return STEP;}
do              {return DO;}
done            {return DONE;}
repeat          {return REPEAT;}
stop            {return STOP;}
return          {return RETURN;}

 
 /* 2.5 Literals */
 // TODO

 /* 2.6 Operators */
 // TODO
 
 /* 2.7 Delimiters */
 // TODO
 
 /* 2.8 Code Area */
 // TODO
 
%%
