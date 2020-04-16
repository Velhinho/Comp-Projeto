%{
#include <stdlib.h> 
#include <string.h> 
#include "node.h" 
#include "y.tab.h" 

char *dupstr(const char *s);
extern void yyerror(const char *msg);
%}


%x CODE AFTEREND COMMENT

whiteSpace [ \n\r\t]+
anyChar .|\n
singleComment "$$"
multiCommentInit '$'
multiCommentEnd '$'
letter [a-zA-Z]
digit [0-9]
id {letter}({letter}|{digit}|_)*

decimalBase [1-9]\.
decimalDigit {digit}
octalBase 0
octalDigit [0-7]
hexaBase 0x
hexaDigit [0-9a-fA-F]
binaryBase 0b
binaryDigit [0-1]

initChar \'
endChar \'
specialChar \\[nrt]
hexaChar \\({hexaDigit}|{hexaDigit}{hexaDigit})

initString \"
endString \"


%%

"module"            {BEGIN CODE; return MODULE;}
"program"           {BEGIN CODE; return PROGRAM;}
{letter}+           {/* ignore */}
.|\n                {/* ignore */}

<AFTEREND>.|\n      ;

 /* 2.4 Keywords */
<CODE>"start"             return START;
<CODE>"void"              return VOID;
<CODE>"const"             return CONST;
<CODE>"number"            return NUMBER;
<CODE>"array"             return ARRAY;
<CODE>"string"            return STRING;
<CODE>"function"          return FUNCTION;
<CODE>"public"            return PUBLIC;
<CODE>"forward"           return FORWARD;
<CODE>"if"                return IF;
<CODE>"else"              return ELSE;
<CODE>"then"              return THEN;
<CODE>"elif"              return ELIF;
<CODE>"fi"                return FI;
<CODE>"for"               return FOR;
<CODE>"until"             return UNTIL;
<CODE>"step"              return STEP;
<CODE>"do"                return DO;
<CODE>"done"              return DONE;
<CODE>"repeat"            return REPEAT;
<CODE>"stop"              return STOP;
<CODE>"return"            return RETURN;

<CODE>"end"               {BEGIN AFTEREND; return END;}


 /* 2.6 Operators */
<CODE>[-+*/%<>=|&~?\^]    return *yytext;
<CODE>":="                return ASG;
<CODE>">="                return GE;
<CODE>"<="                return LE;
<CODE>"~="                return NE;

 /* 2.2 Comments */
<CODE>{singleComment} {BEGIN COMMENT;}
<CODE>{multiCommentInit}{anyChar}+{multiCommentEnd} {/* ignore */}

<COMMENT>.*     {/* ignore */}
<COMMENT>\n     {BEGIN CODE;}

 /* 2.3 Identifiers */
<CODE>{id} { yylval.s = dupstr(yytext); return ID; }

<CODE>[1-9]{digit}* { yylval.i = strtol(yytext, 0, 10); return INTEGER; }
<CODE>{decimalBase}{decimalDigit}+ {/*return DECIMAL;*/}
<CODE>{octalBase}{octalDigit}* { yylval.i = strtol(yytext, NULL, 8); return INTEGER; }
<CODE>{hexaBase}{hexaDigit}+ { yylval.i = strtol(yytext, NULL, 16); return INTEGER; }
<CODE>{binaryBase}{binaryDigit}+ { yylval.i = strtol(yytext, NULL, 2); return INTEGER; }

<CODE>{initChar}([^\\\^\']|{specialChar}|{hexaChar}){endChar} { yytext[yyleng-1] = 0; yylval.s = dupstr(yytext+1); return STRING; }
<CODE>{initString}([^\"]|"\\\"")*{endString} { yytext[yyleng-1] = 0; yylval.s = dupstr(yytext+1); return STRING; }

 /* 2.7 Delimiters */
<CODE>[#\[\]();!,] return *yytext;

 /* 2.1 white space */
<CODE>{whiteSpace}    {/* ignore */}

<CODE>.			yyerror("Unknown character");

%%

int yywrap(void) { return 1; } 
char *getyytext() { return yytext; }
