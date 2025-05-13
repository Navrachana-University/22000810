%{
#include "devta.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%%

"om namah"          { return START; }
"smaran"            { return END; }
"sthapit"           { return DECLARE; }
"vachan"            { return PRINT; }
"yadi"              { return YADI; }
"anyatha"           { return ANYATHA; }

[0-9]+              { yylval.num = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.id = strdup(yytext); return ID; }

"="                 { return '='; }
";"                 { return ';'; }
"("                 { return '('; }
")"                 { return ')'; }
"{"                 { return '{'; }
"}"                 { return '}'; }
"+"                 { return '+'; }
"-"                 { return '-'; }
"*"                 { return '*'; }
"/"                 { return '/'; }

"=="                { return EQ; }
"!="                { return NEQ; }
"<="                { return LE; }
">="                { return GE; }
"<"                 { return '<'; }
">"                 { return '>'; }
"&&"                { return AND; }
"||"                { return OR; }

[ \t\n]+            ; // ignore whitespace

"//".*              ; // single-line comment
"/*"([^*]|\*+[^*/])*\*+"/"    ; // multi-line comment
.                   { printf("Lexical error: Unknown character '%s'\n", yytext); exit(1); }

%%

int yywrap(void) { return 1; }
