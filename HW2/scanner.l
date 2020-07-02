%{
#include<stdio.h>
#include<string.h>

#include "y.tab.h"

#define MAXLEN 305

typedef enum {
    TYPE_,
    KEY_,
    ID_,
    OP_,
    PUNC_,
    INTEGER_,
    DOUBLE_,
    CHAR_,
    STRING_,
} Token;

int debug = 0;
char cf = 0;   // single-line comment (//) flag
int charCnt = 0;
int lineCnt = 1;
char lineContent[MAXLEN];

void pToken(Token);
void pLine();
void addLineContent();
%}

id  [_a-zA-Z]([_a-zA-Z0-9]*)

%x MULTI_COMMENT

%%

"//"[^\n]*  {
    cf = 1;
    addLineContent();
}
"/*"  {
    BEGIN(MULTI_COMMENT);
    addLineContent();
}
<MULTI_COMMENT>.  {
    addLineContent();
}
<MULTI_COMMENT>"*/" {
    BEGIN(INITIAL);
    addLineContent();
}

void {     pToken(TYPE_); yylval.str = strdup(yytext); return VOID;}
int {      pToken(TYPE_); yylval.str = strdup(yytext); return TYPE;}
double {   pToken(TYPE_); yylval.str = strdup(yytext); return TYPE;}
float {    pToken(TYPE_); yylval.str = strdup(yytext); return TYPE;}
char {     pToken(TYPE_); yylval.str = strdup(yytext); return TYPE;}
const {    pToken(KEY_);  yylval.str = strdup(yytext); return CONST; }
NULL {     pToken(KEY_);}
for {      pToken(KEY_);  yylval.str = strdup(yytext); return FOR;}
do {       pToken(KEY_);  yylval.str = strdup(yytext); return DO;}
while {    pToken(KEY_);  yylval.str = strdup(yytext); return WHILE;}
break {    pToken(KEY_);  yylval.str = strdup(yytext); return BREAK;}
continue { pToken(KEY_);  yylval.str = strdup(yytext); return CONTINUE;}
if {       pToken(KEY_);  yylval.str = strdup(yytext); return IF;}
else {     pToken(KEY_);  yylval.str = strdup(yytext); return ELSE;}
return {   pToken(KEY_);  yylval.str = strdup(yytext); return RET;}
struct {   pToken(KEY_);}
switch {   pToken(KEY_);  yylval.str = strdup(yytext); return SWITCH;}
case {     pToken(KEY_);  yylval.str = strdup(yytext); return CASE;}
default {  pToken(KEY_);  yylval.str = strdup(yytext); return DEFAULT;}

{id} {     pToken(ID_); yylval.str = strdup(yytext); return ID;}

"++" {     pToken(OP_); yylval.str = strdup(yytext); return INC;}
"--" {     pToken(OP_); yylval.str = strdup(yytext); return DEC;}
"==" {     pToken(OP_); yylval.str = strdup(yytext); return EQUAL; }
"<=" {     pToken(OP_); yylval.str = strdup(yytext); return L_EQUAL; }
">=" {     pToken(OP_); yylval.str = strdup(yytext); return G_EQUAL; }
"!=" {     pToken(OP_); yylval.str = strdup(yytext); return N_EQUAL; }
"&&" {     pToken(OP_); yylval.str = strdup(yytext); return LOGIC_AND; }
"||" {     pToken(OP_); yylval.str = strdup(yytext); return LOGIC_OR; }
"+" {      pToken(OP_); yylval.str = strdup(yytext); return PLUS;}
"-" {      pToken(OP_); yylval.str = strdup(yytext); return MINUS;}
"*" {      pToken(OP_); yylval.str = strdup(yytext); return MUL;}
"/" {      pToken(OP_); yylval.str = strdup(yytext); return DIV;}
"%" {      pToken(OP_); yylval.str = strdup(yytext); return MOD;}
"<" {      pToken(OP_); yylval.str = strdup(yytext); return LESS; }
">" {      pToken(OP_); yylval.str = strdup(yytext); return GREATER; }
"=" {      pToken(OP_); yylval.str = strdup(yytext); return ASSIGN;}
"!" {      pToken(OP_); yylval.str = strdup(yytext); return NEG;}
"&" {      pToken(OP_); yylval.str = strdup(yytext); return BITWISE_AND; }
"|" {      pToken(OP_); yylval.str = strdup(yytext); return BITWISE_OR; }

":" {      pToken(PUNC_); yylval.str = strdup(yytext); return COLON;}
";" {      pToken(PUNC_); yylval.str = strdup(yytext); return SEMICOLON;}
"," {      pToken(PUNC_); yylval.str = strdup(yytext); return COMMA;}
"." {      pToken(PUNC_);}
"[" {      pToken(PUNC_); yylval.str = strdup(yytext); return L_BRKT;}
"]" {      pToken(PUNC_); yylval.str = strdup(yytext); return R_BRKT;}
"(" {      pToken(PUNC_); yylval.str = strdup(yytext); return L_PARA;}
")" {      pToken(PUNC_); yylval.str = strdup(yytext); return R_PARA;}
"{" {      pToken(PUNC_); yylval.str = strdup(yytext); return L_CURV;}
"}" {      pToken(PUNC_); yylval.str = strdup(yytext); return R_CURV;}

([0-9]+) {             pToken(INTEGER_); yylval.i_val = atoi(yytext); return INTEGER;}
([0-9]*)"."([0-9]+) {  pToken(DOUBLE_);  yylval.d_val = atof(yytext); return DOUBLE;}
([0-9]+)"."([0-9]*) {  pToken(DOUBLE_);  yylval.d_val = atof(yytext); return DOUBLE;}
\'([^\\\']|\\.)\' {    pToken(CHAR_);    yylval.str = strdup(yytext); return CHAR;}
\"([^\\\"]|\\.)*\" {   pToken(STRING_);  yylval.str = strdup(yytext); return STRING;}

<*>[ \t]+ {
    addLineContent();
}

<*>\n   {
    cf = 0;
    pLine();
}

%%

/*
int main(void)
{
    yylex();
    return 0;
}
*/

void pToken(Token tok)
{
    if(debug)
    {
        if(!cf)
        {
            printf("#token ");
            switch(tok) {
                case KEY_:
                    printf("key");
                    break;
                case ID_:
                    printf("id");
                    break;
                case OP_:
                    printf("op");
                    break;
                case PUNC_:
                    printf("punc");
                    break;
                case INTEGER_:
                    printf("integer");
                    break;
                case DOUBLE_:
                    printf("double");
                    break;
                case CHAR_:
                    printf("char");
                    break;
                case STRING_:
                    printf("string");
                    break;

            }
            printf(":%s\n", yytext);
        }

        addLineContent();
    }
}

void pLine()
{
    if(debug)
    {
        printf("%d:%s\n", lineCnt, lineContent);

        // lineCnt
        lineCnt++;
        // Init
        memset(lineContent, 0, sizeof(char)*MAXLEN);
        charCnt = 0;
    }
}

void addLineContent()
{
    if(debug)
    {
        strcpy(lineContent+charCnt, yytext);
        charCnt += yyleng;
    }
}
