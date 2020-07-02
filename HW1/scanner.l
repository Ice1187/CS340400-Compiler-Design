%{
#include<stdio.h>
#include<string.h>

#define MAXLEN 305

typedef enum {
    KEY,
    ID,
    OP,
    PUNC,
    INTEGER,
    DOUBLE,
    CHAR,
    STRING,
} Token;

char sf = 1;   // source flag
char tf = 1;   // token flag
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

"#pragma"[ \t]+"token"[ \t]+"on" {
    tf = 1;
    addLineContent();
}
"#pragma"[ \t]+"token"[ \t]+"off" {
    tf = 0;
    addLineContent();
}
"#pragma"[ \t]+"source"[ \t]+"on" {
    sf = 1;
    addLineContent();
}
"#pragma"[ \t]+"source"[ \t]+"off" {
    sf = 0;
    addLineContent();
}

void {  
    pToken(KEY);
}
const { 
    pToken(KEY);
}
NULL {
    pToken(KEY);
}
for {
    pToken(KEY);
}
do {
    pToken(KEY);
}
while {
    pToken(KEY);
}
break {
    pToken(KEY);
}
continue {
    pToken(KEY);
}
if {
    pToken(KEY);
}
else {
    pToken(KEY);
}
return {
    pToken(KEY);
}
struct {
    pToken(KEY);
}
switch {
    pToken(KEY);
}
case {
    pToken(KEY);
}
default {
    pToken(KEY);
}
int {
    pToken(KEY);
}
double {
    pToken(KEY);
}
float {
    pToken(KEY);
}
char {
    pToken(KEY);
}
fclose {
    pToken(KEY);
}
clearerr {
    pToken(KEY);
}
feof {
    pToken(KEY);
}
ferror {
    pToken(KEY);
}
fflush {
    pToken(KEY);
}
fgetpos {
    pToken(KEY);
}
fopen {
    pToken(KEY);
}
fread {
    pToken(KEY);
}
freopen {
    pToken(KEY);
}
fseek {
    pToken(KEY);
}
fsetpos {
    pToken(KEY);
}
ftell {
    pToken(KEY);
}
fwrite {
    pToken(KEY);
}
remove {
    pToken(KEY);
}
rename {
    pToken(KEY);
}
rewind {
    pToken(KEY);
}
setbuf {
    pToken(KEY);
}
setvbuf {
    pToken(KEY);
}
tmpfile {
    pToken(KEY);
}
tmpnam {
    pToken(KEY);
}
fprintf {
    pToken(KEY);
}
printf {
    pToken(KEY);
}
sprintf {
    pToken(KEY);
}
vfprintf {
    pToken(KEY);
}
vprintf {
    pToken(KEY);
}
vsprintf {
    pToken(KEY);
}
fscanf {
    pToken(KEY);
}
scanf {
    pToken(KEY);
}
sscanf {
    pToken(KEY);
}
fgetc {
    pToken(KEY);
}
fgets {
    pToken(KEY);
}
fputc {
    pToken(KEY);
}
fputs {
    pToken(KEY);
}
getc {
    pToken(KEY);
}
getchar {
    pToken(KEY);
}
gets {
    pToken(KEY);
}
putc {
    pToken(KEY);
}
putchar {
    pToken(KEY);
}
puts {
    pToken(KEY);
}
ungetc {
    pToken(KEY);
}
perror {
    pToken(KEY);
}

{id} {      
    pToken(ID);
}

"++" {
    pToken(OP);
}
"--" {
    pToken(OP);
}
"==" {
    pToken(OP);    
}
"<=" {
    pToken(OP);    
}
">=" {
    pToken(OP);    
}
"!=" {
    pToken(OP);    
}
"&&" {
    pToken(OP);    
}
"||" {
    pToken(OP);    
}
"+" {
    pToken(OP);    
}
"-" {
    pToken(OP);    
}
"*" {
    pToken(OP);    
}
"/" {
    pToken(OP);    
}
"%" {
    pToken(OP);    
}
"<" {
    pToken(OP);    
}
">" {
    pToken(OP);    
}
"=" {
    pToken(OP);    
}
"!" {
    pToken(OP);    
}
"&" {
    pToken(OP);    
}
"|" {
    pToken(OP);    
}
":" {
    pToken(PUNC);    
}
";" {
    pToken(PUNC);    
}
"," {
    pToken(PUNC);    
}
"." {
    pToken(PUNC);    
}
"[" {
    pToken(PUNC);    
}
"]" {
    pToken(PUNC);    
}
"(" {
    pToken(PUNC);    
}
")" {
    pToken(PUNC);    
}
"{" {
    pToken(PUNC);    
}
"}" {
    pToken(PUNC);    
}

[+-]?([0-9]+) {
    pToken(INTEGER);    
}

[+-]?([0-9]*)"."([0-9]+) {
    pToken(DOUBLE);    
}
[+-]?([0-9]+)"."([0-9]*) {
    pToken(DOUBLE);    
}

\'([^\\\']|\\.)\' {
    pToken(CHAR);    
}

\"([^\\\"]|\\.)*\" {
    pToken(STRING);    
}

<*>[ \t]+ {
    addLineContent();
}

<*>\n   {
    cf = 0;
    pLine();
}

%%

int main(void)
{
    yylex();
    return 0;
}

void pToken(Token tok)
{
    if(tf && !cf)
    {
        printf("#token ");
        switch(tok) {
            case KEY:
                printf("key");
                break;
            case ID:
                printf("id");
                break;
            case OP:
                printf("op");
                break;
            case PUNC:
                printf("punc");
                break;
            case INTEGER:
                printf("integer");
                break;
            case DOUBLE:
                printf("double");
                break;
            case CHAR:
                printf("char");
                break;
            case STRING:
                printf("string");
                break;
            
        }
        printf(":%s\n", yytext);
    }

    addLineContent();
}

void pLine() 
{
    if(sf)
        printf("%d:%s\n", lineCnt, lineContent);
    
    // lineCnt
    lineCnt++;
    // Init 
    memset(lineContent, 0, sizeof(char)*MAXLEN);
    charCnt = 0;
}

void addLineContent()
{
    if(sf) {
        strcpy(lineContent+charCnt, yytext);
        charCnt += yyleng;
    }
}