%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern char* yytext;
int yyerror(const char* s);

int tempCount = 1;
int labelCount = 1;
%}

%union {
    int num;
    char* id;
    char* code;
}

%token <num> NUMBER
%token <id> ID
%token START END DECLARE PRINT YADI ANYATHA FUNCTION RETURN CALL
%token EQ NEQ LE GE

%type <code> program stmt stmt_list block expr cond func_def

%%

program:
    START stmt_list END {
        printf("%s", $2);
        printf("TAC generation completed.\n");
        free($2);
    }
;

stmt_list:
    stmt_list stmt {
        $$ = malloc(strlen($1) + strlen($2) + 1);
        strcpy($$, $1);
        strcat($$, $2);
        free($1); free($2);
    }
    | stmt {
        $$ = $1;
    }
;

stmt:
    DECLARE ID '=' expr ';' {
        char *code = malloc(strlen($4) + 50);
        char temp[10];
        sprintf(temp, "t%d", tempCount - 1);
        sprintf(code, "%s%s = %s\n", $4, $2, temp);
        $$ = code;
        free($4);
    }
    | PRINT ID ';' {
        char *code = malloc(50);
        sprintf(code, "vachan %s\n", $2);
        $$ = code;
    }
    | YADI '(' cond ')' block ANYATHA block {
        char *code = malloc(strlen($5) + strlen($7) + strlen($3) + 200);
        int trueLabel = labelCount++;
        int falseLabel = labelCount++;
        int endLabel = labelCount++;

        sprintf(code,
            "%sIF t%d GOTO L%d\n"
            "GOTO L%d\n"
            "L%d:\n"
            "%s"
            "GOTO L%d\n"
            "L%d:\n"
            "%s"
            "L%d:\n",
            $3, tempCount - 1, trueLabel,
            falseLabel,
            trueLabel, $5,
            endLabel,
            falseLabel, $7,
            endLabel
        );
        $$ = code;
        free($5); free($7); free($3);
    }
    | func_def {
        $$ = $1;
    }
    | RETURN ID ';' {
        char *code = malloc(100);
        sprintf(code, "RETURN %s\n", $2);
        $$ = code;
    }
    | CALL ID '(' ')' ';' {
        char *code = malloc(100);
        sprintf(code, "CALL %s\n", $2);
        $$ = code;
    }
;

func_def:
    FUNCTION ID '(' ')' block {
        char *code = malloc(strlen($5) + 100);
        sprintf(code, "FUNC %s:\n%sENDFUNC\n", $2, $5);
        $$ = code;
        free($5);
    }
    | CALL ID '(' ')' block {
        char *code = malloc(strlen($5) + 100);
        sprintf(code, "FUNC %s:\n%sENDFUNC\n", $2, $5);
        $$ = code;
        free($5);
    }
;

block:
    '{' stmt_list '}' {
        $$ = $2;
    }
;

expr:
    NUMBER {
        char *code = malloc(30);
        sprintf(code, "t%d = %d\n", tempCount++, $1);
        $$ = code;
    }
    | ID {
        char *code = malloc(30);
        sprintf(code, "t%d = %s\n", tempCount++, $1);
        $$ = code;
    }
    | ID '+' ID {
        char *code = malloc(100);
        sprintf(code, "t%d = %s + %s\n", tempCount++, $1, $3);
        $$ = code;
    }
    | ID '-' ID {
        char *code = malloc(100);
        sprintf(code, "t%d = %s - %s\n", tempCount++, $1, $3);
        $$ = code;
    }
    | ID '*' ID {
        char *code = malloc(100);
        sprintf(code, "t%d = %s * %s\n", tempCount++, $1, $3);
        $$ = code;
    }
    | ID '/' ID {
        char *code = malloc(100);
        sprintf(code, "t%d = %s / %s\n", tempCount++, $1, $3);
        $$ = code;
    }
;

cond:
    ID '<' ID {
        char *code = malloc(100);
        sprintf(code, "t%d = %s < %s\n", tempCount++, $1, $3);
        $$ = code;
    }
    | ID '>' ID {
        char *code = malloc(100);
        sprintf(code, "t%d = %s > %s\n", tempCount++, $1, $3);
        $$ = code;
    }
    | ID EQ ID {
        char *code = malloc(100);
        sprintf(code, "t%d = %s == %s\n", tempCount++, $1, $3);
        $$ = code;
    }
    | ID NEQ ID {
        char *code = malloc(100);
        sprintf(code, "t%d = %s != %s\n", tempCount++, $1, $3);
        $$ = code;
    }
;

%%

int yyerror(const char* s) {
    fprintf(stderr, "Syntax Error: %s at '%s'\n", s, yytext);
    return 1;
}

int main() {
    return yyparse();
}