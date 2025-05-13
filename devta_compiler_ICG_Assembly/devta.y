%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern char* yytext;
int yyerror(const char* s);

int tempCount = 1;
int labelCount = 1;

char tacBuffer[10000] = "";
char asmBuffer[10000] = "";

void append_code(char* buffer, const char* code) {
    strcat(buffer, code);
    strcat(buffer, "\n");
}

char* create_temp() {
    char* temp = malloc(10);
    sprintf(temp, "t%d", tempCount++);
    return temp;
}

char* create_cond_code(char* left, const char* op, char* right) {
    char* temp = create_temp();
    char line[100];
    sprintf(line, "%s = %s %s %s", temp, left, op, right);
    append_code(tacBuffer, line);

    sprintf(line, "MOV R%d, %s", tempCount - 1, left);
    append_code(asmBuffer, line);
    sprintf(line, "CMP R%d, %s", tempCount - 1, right);
    append_code(asmBuffer, line);

    return temp;
}

char* int_to_string(int val) {
    char* str = malloc(20);
    sprintf(str, "%d", val);
    return str;
}
%}

%union {
    int num;
    char* id;
    char* code;
}

%token <num> NUMBER
%token <id> ID STRING
%token START END DECLARE PRINT YADI ANYATHA WHILE
%token EQ NEQ LE GE AND OR

%type <code> program stmt stmt_list block expr cond

%%

program:
    START stmt_list END {
        printf("\n=== Three Address Code (TAC) ===\n%s", tacBuffer);
        printf("\n=== Assembly Code ===\n%s", asmBuffer);
        printf("\nCompilation completed.\n");
    }
    | START error END { yyerror("Syntax error in program body."); }
;

stmt_list:
    stmt_list stmt {
        char* temp = malloc(strlen($1) + strlen($2) + 2);  // Combine previous code with new code
        strcpy(temp, $1);
        strcat(temp, $2);
        $$ = temp;  // $2 contains the new statement's code
    }
  | stmt { $$ = $1; }  // If it's the first statement, return it directly
;

stmt:
    DECLARE ID '=' expr ';' {
    char line[100];
    sprintf(line, "%s = t%d", $2, tempCount - 1);  // TAC code
    append_code(tacBuffer, line);

    sprintf(line, "MOV %s, R%d", $2, tempCount - 1);  // Assembly code
    append_code(asmBuffer, line);

    char* code = malloc(200);
    sprintf(code, "%s\nMOV %s, R%d\n", line, $2, tempCount - 1);  // Combine both codes
    $$ = code;
}
| PRINT ID ';' {
    char line[100];
    sprintf(line, "vachan %s", $2);  // TAC code
    append_code(tacBuffer, line);

    sprintf(line, "PRINT %s", $2);  // Assembly code
    append_code(asmBuffer, line);

    char* code = malloc(200);
    sprintf(code, "%s\nvachan %s\n", line, $2);  // Combine both codes
    $$ = code;
}
    | YADI '(' cond ')' block ANYATHA block {
    int t = tempCount - 1;
    int trueLabel = labelCount++;  // Label for the 'then' block
    int falseLabel = labelCount++; // Label for the 'else' block
    int endLabel = labelCount++;   // End label for the whole if statement

    char line[200];

    // Generate TAC and ASM for the condition check
    sprintf(line, "IF t%d GOTO L%d", t, trueLabel);
    append_code(tacBuffer, line);
    append_code(asmBuffer, line);

    // Jump to falseLabel if the condition is false
    sprintf(line, "GOTO L%d", falseLabel);
    append_code(tacBuffer, line);
    append_code(asmBuffer, line);

    // True label: Enter the 'then' block
    sprintf(line, "L%d:", trueLabel);
    append_code(tacBuffer, line);
    append_code(asmBuffer, line);

    // Append code from the 'then' block (statements inside block)
    if ($5) {
        append_code(tacBuffer, $5);
        append_code(asmBuffer, $5);
    }

    // Jump to the end label after the 'then' block
    sprintf(line, "GOTO L%d", endLabel);
    append_code(tacBuffer, line);
    append_code(asmBuffer, line);

    // False label: Enter the 'else' block
    sprintf(line, "L%d:", falseLabel);
    append_code(tacBuffer, line);
    append_code(asmBuffer, line);

    // Append code from the 'else' block (statements inside block)
    if ($7) {
        append_code(tacBuffer, $7);
        append_code(asmBuffer, $7);
    }

    // End label
    sprintf(line, "L%d:", endLabel);
    append_code(tacBuffer, line);
    append_code(asmBuffer, line);
}
;

block:
    '{' stmt_list '}' { $$ = $2; }
    | '{' error '}' { yyerror("Error inside block."); }
;

expr:
    NUMBER {
        char* temp = create_temp();
        char line[100];
        sprintf(line, "%s = %d", temp, $1);
        append_code(tacBuffer, line);
        sprintf(line, "MOV R%d, #%d", tempCount - 1, $1);
        append_code(asmBuffer, line);
    }
    | ID {
        char* temp = create_temp();
        char line[100];
        sprintf(line, "%s = %s", temp, $1);
        append_code(tacBuffer, line);
        sprintf(line, "MOV R%d, %s", tempCount - 1, $1);
        append_code(asmBuffer, line);
    }
    | ID '+' ID {
        char* temp = create_temp();
        char line[100];
        sprintf(line, "%s = %s + %s", temp, $1, $3);
        append_code(tacBuffer, line);
        sprintf(line, "MOV R%d, %s", tempCount - 1, $1);
        append_code(asmBuffer, line);
        sprintf(line, "ADD R%d, %s", tempCount - 1, $3);
        append_code(asmBuffer, line);
    }
    | ID '-' ID {
        char* temp = create_temp();
        char line[100];
        sprintf(line, "%s = %s - %s", temp, $1, $3);
        append_code(tacBuffer, line);
        sprintf(line, "MOV R%d, %s", tempCount - 1, $1);
        append_code(asmBuffer, line);
        sprintf(line, "SUB R%d, %s", tempCount - 1, $3);
        append_code(asmBuffer, line);
    }
    | ID '*' ID {
        char* temp = create_temp();
        char line[100];
        sprintf(line, "%s = %s * %s", temp, $1, $3);
        append_code(tacBuffer, line);
        sprintf(line, "MOV R%d, %s", tempCount - 1, $1);
        append_code(asmBuffer, line);
        sprintf(line, "MUL R%d, %s", tempCount - 1, $3);
        append_code(asmBuffer, line);
    }
    | ID '/' ID {
        char* temp = create_temp();
        char line[100];
        sprintf(line, "%s = %s / %s", temp, $1, $3);
        append_code(tacBuffer, line);
        sprintf(line, "MOV R%d, %s", tempCount - 1, $1);
        append_code(asmBuffer, line);
        sprintf(line, "DIV R%d, %s", tempCount - 1, $3);
        append_code(asmBuffer, line);
    }
;

cond:
    ID '<' ID         { $$= create_cond_code($1, "<", $3); }
    | ID '<' NUMBER     {$$ = create_cond_code($1, "<", int_to_string($3)); }
    | NUMBER '<' ID     { $$= create_cond_code(int_to_string($1), "<", $3); }
    | NUMBER '<' NUMBER {$$ = create_cond_code(int_to_string($1), "<", int_to_string($3)); }
    | ID '>' ID         { $$= create_cond_code($1, ">", $3); }
    | ID '>' NUMBER     {$$ = create_cond_code($1, ">", int_to_string($3)); }
    | NUMBER '>' ID     { $$= create_cond_code(int_to_string($1), ">", $3); }
    | NUMBER '>' NUMBER {$$ = create_cond_code(int_to_string($1), ">", int_to_string($3)); }
    | ID EQ ID          { $$= create_cond_code($1, "==", $3); }
    | ID NEQ ID         {$$ = create_cond_code($1, "!=", $3); }
    | ID LE ID          { $$= create_cond_code($1, "<=", $3); }
    | ID GE ID          { $$= create_cond_code($1, ">=", $3); }
;

%%

int main() {
    yyparse();
    return 0;
}

int yyerror(const char *s) {
    fprintf(stderr, "Error: %s at or near '%s'\n", s, yytext);
    return 1;
}
