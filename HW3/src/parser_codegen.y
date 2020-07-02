%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "codegen.h"

int yylex(void);

char* int2chr(int);
char* dul2chr(double);
char* str2chr(char *);
char* get_non_term0(const char *);
char* get_non_term1(const char *, char *);
char* get_non_term2(const char * ,char *, char *);
char* get_non_term3(const char * ,char *, char *, char *);
char* get_non_term4(const char * ,char *, char *, char *, char *);
char* get_non_term5(const char * ,char *, char *, char *, char *, char *);
char* get_non_term6(const char * ,char *, char *, char *, char *, char *, char *);
char* get_non_term7(const char * ,char *, char *, char *, char *, char *, char *, char *);

int p_debug = 0;

int scope_cnt;
int offset;
void install_sym(Variant, char *, Type, int, int, int, int, int);

Type str2type(char *);

%}

%union{
    int i_val;
    double d_val;
    char* str;
}

%token <str> DWRITE DELAY
%token <str> BREAK CONTINUE RET
%token <str> FOR
%token <str> DO WHILE
%token <str> SWITCH CASE DEFAULT
%token <str> VOID TYPE ID OP PUNC CHAR STRING CONST
%token <str> COMMA SEMICOLON COLON
%token <str> LOGIC_OR LOGIC_AND BITWISE_OR BITWISE_AND
%token <str> EQUAL N_EQUAL G_EQUAL L_EQUAL GREATER LESS
%token <str> PLUS MINUS MUL DIV MOD
%token <str> NEG INC DEC
%token <str> L_BRKT R_BRKT L_CURV R_CURV L_PARA R_PARA
%token <i_val> INTEGER
%token <d_val> DOUBLE
%token <str> CHAR
%token <str> ASSIGN
%token <str> IF ELSE

%type <str> stmt_condi
%type <str> stmt_for for_ctnt expr_
%type <str> stmt_while
%type <str> stmt_switch swth_clauses swth_clause
%type <str> stmt_if if_head
%type <str> stmt_expr
%type <str> comp_stmt stmts stmt var_decl
%type <str> fn_def fn_head
%type <str> fn_decl fn_params fn_param
%type <str> const_decl const_idents const_ident
%type <str> array_decl arrays array_init array arr_brkts arr_brkt int_liter sign arr_ctnts arr_ctnt
%type <str> scalar_decl idents ident_init
%type <str> expr
%type <str> e_logic_or e_logic_and e_bitwise_or e_bitwise_and
%type <str> e_equal e_greater
%type <str> e_add_sub e_mul_div_mod
%type <str> e_unary
%type <str> e_top
%type <str> brkts_e brkt_e call_fn params

%type <str> plus_minus mul_div_mod inc_dec
%type <str> CONSTANT VAR LITER char_

%right ASSIGN
%left LOGIC_OR
%left LOGIC_AND
%left BITWISE_OR
%left BITWISE_AND
%left EQUAL N_EQUAL
%left GREATER LESS G_EQUAL L_EQUAL
%right NEG

%%

/*-------- program --------*/
programs: programs program
        | program
        ;

program: fn_def { 
        // printf("%s", $1); free($1); 
            }
       | fn_decl { 
        //   printf("%s", $1); free($1); 
            }
       | const_decl { 
        //    printf("%s", $1); free($1); 
            }
       | array_decl { 
        //    printf("%s", $1); free($1); 
           }
       | scalar_decl { 
        //    printf("%s", $1); free($1); 
           }
       ;

/*-------- stmt --------*/
stmts: stmts stmt {
        $$ = get_non_term2("", $1, $2);
        }
     | stmt
     ;

stmt: stmt_expr { $$ = get_non_term1("stmt", $1); }
    | stmt_if { $$ = get_non_term1("stmt", $1); }
    | stmt_switch { $$ = get_non_term1("stmt", $1); }
    | stmt_while { $$ = get_non_term1("stmt", $1); }
    | stmt_for { $$ = get_non_term1("stmt", $1); }
    | stmt_condi { $$ = get_non_term1("stmt", $1); }
    | stmt_dwrite {}
    | stmt_delay {}
    | var_decl
    | comp_stmt { $$ = get_non_term1("stmt", $1); }
    ;

comp_stmt: L_CURV stmts R_CURV {
             $$ = get_non_term3("", $1, $2, $3);
             }
         | L_CURV R_CURV {
            $$ = get_non_term2("", $1, $2);
             }
         ;

stmt_expr: expr SEMICOLON {
             $$ = get_non_term2("", $1, $2);
             }
         ;

stmt_if: if_head ELSE comp_stmt {
           $$ = get_non_term3("", $1, $2, $3);
           }
       | if_head
       ;

stmt_switch: SWITCH L_PARA expr R_PARA L_CURV swth_clauses R_CURV {
               $$ = get_non_term7("", $1, $2, $3, $4, $5, $6, $7);
               }
           | SWITCH L_PARA expr R_PARA L_CURV R_CURV {
               $$ = get_non_term6("", $1, $2, $3, $4, $5, $6);
               }
           ;

swth_clauses: swth_clauses swth_clause {
                $$ = get_non_term2("", $1, $2);
                }
            | swth_clause
            ;

swth_clause: CASE int_liter COLON stmts {
               $$ = get_non_term4("", $1, $2, $3, $4);
               }
           | CASE int_liter COLON {
               $$ = get_non_term3("", $1, $2, $3);
               }
           | DEFAULT COLON stmts {
               $$ = get_non_term3("", $1, $2, $3);
               }
           | DEFAULT COLON {
               $$ = get_non_term2("", $1, $2);
           }

stmt_while: WHILE L_PARA expr R_PARA stmt {
              $$ = get_non_term5("", $1, $2, $3, $4, $5);
              }
          | DO stmt WHILE L_PARA expr R_PARA SEMICOLON {
              $$ = get_non_term7("", $1, $2, $3, $4, $5, $6, $7);
              }
          ;

stmt_for: FOR L_PARA for_ctnt R_PARA stmt {
            $$ = get_non_term5("", $1, $2, $3, $4, $5);
            }
        ;

for_ctnt: expr_ SEMICOLON expr_ SEMICOLON expr_ {
            $$ = get_non_term5("", $1, $2, $3, $4, $5);
            }
        ;

expr_: expr
     | /* empty */ { $$ = get_non_term0(""); }
     ;

stmt_condi: RET expr SEMICOLON { $$ = get_non_term3("", $1, $2, $3); }
          | RET SEMICOLON { $$ = get_non_term2("", $1, $2); }
          | BREAK SEMICOLON { $$ = get_non_term2("", $1, $2); }
          | CONTINUE SEMICOLON { $$ = get_non_term2("", $1, $2); }
          ;

if_head: IF L_PARA expr R_PARA comp_stmt {
           $$ = get_non_term5("", $1, $2, $3, $4, $5);
}

stmt_dwrite: DWRITE L_PARA INTEGER COMMA INTEGER R_PARA SEMICOLON {
                cg_dwrite($3, $5);
            }
           ;

stmt_delay: DELAY L_PARA expr R_PARA SEMICOLON {
                cg_delay();
            }
          ;

var_decl: const_decl
        | array_decl
        | scalar_decl
        ;

/*-------- function --------*/
fn_def: TYPE fn_head L_CURV {
        //    $$ = get_non_term3("func_def", $1, $2, $3);
            if(get_sym_idx($2)==-1)
            {
                cg_fn_decl_by_name($2);
                install_sym(V_FN, $2, str2type($1), scope_cnt, 0, 0, offset, 0);
            }
            offset = 0;
            cg_fn_start($2);
            scope_cnt++;
            }
           stmts R_CURV {
            cg_fn_end();
            scope_cnt--;
           }
      | VOID fn_head L_CURV {
        //    $$ = get_non_term3("func_def", $1, $2, $3);
            if(get_sym_idx($2)==-1)
            {
                cg_fn_decl_by_name($2);
                install_sym(V_FN, $2, str2type($1), scope_cnt, 0, 0, offset, 0);
            }
            cg_fn_start($2);
            offset = 0;
            scope_cnt++;
           } 
           stmts R_CURV {
               cg_fn_end();
               scope_cnt--;
           } 
      ;

fn_decl: TYPE fn_head SEMICOLON {
        //    $$ = get_non_term3("func_decl", $1, $2, $3);
            cg_fn_decl_by_name($2);
            install_sym(V_FN, $2, str2type($1), scope_cnt, 0, 0, offset, 0);
        }
       | VOID fn_head SEMICOLON {
        //    $$ = get_non_term3("func_decl", $1, $2, $3);
            cg_fn_decl_by_name($2);
            install_sym(V_FN, $2, str2type($1), scope_cnt, 0, 0, offset, 0);
       }
       ;

fn_head: ID L_PARA fn_params R_PARA {
        //    $$ = get_non_term4("", $1, $2, $3, $4);
            $$ = $1;
           }
        ;

fn_params: fn_params COMMA fn_param {
            //  $$ = get_non_term3("", $1, $2, $3);
            }
         | fn_param
         | /* empty */ { 
            //  $$ = get_non_term0(""); 
             }
         ;

fn_param: TYPE ID {
            // $$ = get_non_term2("", $1, $2);
            install_sym(V_ARG, $2, str2type($1), scope_cnt, offset, 0, 0, 0);
            offset++;
            }
        ;

/*-------- const --------*/
const_decl: CONST TYPE const_idents SEMICOLON {
              $$ = get_non_term4("const_decl", $1, $2, $3, $4);
              }
          ;

const_idents: const_idents COMMA const_ident {
                $$ = get_non_term3("", $1, $2, $3);
                }
            | const_ident
            ;

const_ident: ID ASSIGN expr {
              $$ = get_non_term3("", $1, $2, $3);
              }
            ;
/*-------- array --------*/
array_decl: TYPE arrays SEMICOLON {
              $$ = get_non_term3("array_decl", $1, $2, $3);
              }
          ;

arrays: arrays COMMA array_init {
          $$ = get_non_term3("", $1, $2, $3);
          }
      | array_init
      ;

array_init: array ASSIGN L_CURV arr_ctnts R_CURV {
              $$ = get_non_term5("", $1, $2, $3, $4, $5);
              }
          | array
          ;

array: ID arr_brkts {
         $$ = get_non_term2("", $1, $2);
         }
     ;

arr_brkts: arr_brkts arr_brkt {
             $$ = get_non_term2("", $1, $2);
             }
         | arr_brkt
         ;

arr_brkt: L_BRKT int_liter R_BRKT {
            $$ = get_non_term3("", $1, $2, $3);
            }

int_liter: sign INTEGER {
             char *tmp = int2chr($2);
             if(strcmp($1, "+")==0)
             {
                 free($1);
                 $$ = get_non_term1("", tmp);
             }
             else
                $$ = get_non_term2("", $1, tmp);
             }
         ;

sign: plus_minus { $$ = get_non_term1("", $1); }
    | /* empty */ { $$ = get_non_term0(""); }
    ;

arr_ctnts: arr_ctnts COMMA arr_ctnt {
             $$ = get_non_term3("", $1, $2, $3);
             }
         | arr_ctnt
         ;

arr_ctnt: L_CURV arr_ctnts R_CURV {
            $$ = get_non_term3("", $1, $2, $3);
            }
        | expr
        ;

/*-------- scalar --------*/
scalar_decl: TYPE idents SEMICOLON {
            //    $$ = get_non_term3("scalar_decl", $1, $2, $3);
               }
           ;

idents: idents COMMA ident_init {
                // $$ = get_non_term3("", $1, $2, $3);
                }
            | ident_init
            ;

ident_init: ID ASSIGN expr {
            //   $$ = get_non_term3("", $1, $2, $3);
                offset++;
                cg_store_var(offset);
                install_sym(V_VAR, $1, T_INT, scope_cnt, offset, 0, 0, 0);
              }
          | ID { offset++; }
          ;

/*-------- expression --------*/
expr: VAR ASSIGN expr {
        $$ = get_non_term3("expr", $1, $2, $3);
        }
    | e_logic_or
    ;

e_logic_or: e_logic_or LOGIC_OR e_logic_and {
              $$ = get_non_term3("expr", $1, $2, $3);
              }
          | e_logic_and
          ;

e_logic_and: e_logic_and LOGIC_AND e_bitwise_or {
              $$ = get_non_term3("expr", $1, $2, $3);
              }
           | e_bitwise_or
           ;

e_bitwise_or: e_bitwise_or BITWISE_OR e_bitwise_and {
              $$ = get_non_term3("expr", $1, $2, $3);
              }
            | e_bitwise_and
            ;

e_bitwise_and: e_bitwise_and BITWISE_AND e_equal {
                 $$ = get_non_term3("expr", $1, $2, $3);
                 }
             | e_equal
             ;

e_equal: e_equal EQUAL e_greater {
           $$ = get_non_term3("expr", $1, $2, $3);
           }
        | e_equal N_EQUAL e_greater {
           $$ = get_non_term3("expr", $1, $2, $3);
           }
        | e_greater
        ;

e_greater: e_greater GREATER e_add_sub {
             $$ = get_non_term3("expr", $1, $2, $3);
             }
         | e_greater G_EQUAL e_add_sub {
             $$ = get_non_term3("expr", $1, $2, $3);
             }
         | e_greater LESS e_add_sub {
             $$ = get_non_term3("expr", $1, $2, $3);
             }
         | e_greater L_EQUAL e_add_sub {
             $$ = get_non_term3("expr", $1, $2, $3);
             }
         | e_add_sub
         ;

e_add_sub: e_add_sub plus_minus e_mul_div_mod {
            //  $$ = get_non_term3("expr", $1, $2, $3);
                cg_bin_op($2);
             }
         | e_mul_div_mod
         ;

e_mul_div_mod: e_mul_div_mod mul_div_mod e_unary {
                //  $$ = get_non_term3("expr", $1, $2, $3);
                    cg_bin_op($2);
                 }
             | e_unary
             ;

e_unary: NEG e_unary {
           $$ = get_non_term2("expr", $1, $2);
           }
       | plus_minus e_unary %prec NEG {
           $$ = get_non_term2("expr", $1, $2);
           }
       | inc_dec VAR %prec NEG {
           $$ = get_non_term2("expr", $1, $2);
           }
       | e_top
       ;

e_top: VAR inc_dec{
         $$ = get_non_term2("expr", $1, $2);
         }
     | call_fn {
         $$ = get_non_term1("expr", $1);
         }
     | VAR {
         $$ = get_non_term1("expr", $1);
         }
     | LITER {
         $$ = get_non_term1("expr", $1);
         }
     | L_PARA expr R_PARA {
         $$ = get_non_term3("expr", $1, $2, $3);
         }
     ;

plus_minus: PLUS
          | MINUS
          ;

mul_div_mod: MUL
           | DIV
           | MOD
           ;

inc_dec: INC
       | DEC
       ;

call_fn: ID L_PARA params R_PARA {
           $$ = get_non_term4("", $1, $2, $3, $4);
           }
       ;

params: params COMMA expr {
          $$ = get_non_term3("", $1, $2, $3);
          }
      | expr
      | /* empty */ { $$ = get_non_term0(""); }
      ;

VAR: ID brkts_e {
       $$ = get_non_term2("", $1, $2);
       }
   | ID {
       cg_get_var($1);
   }
   ;

LITER: CONSTANT
     | char_
     | STRING
     ;

CONSTANT: INTEGER {
            $$ = int2chr($1);
            cg_constant_int($1);
            }
        | DOUBLE {
            $$ = dul2chr($1);
          }
        ;

brkts_e: brkts_e brkt_e {
           $$ = get_non_term2("", $1, $2);
           }
       | brkt_e
       ;

brkt_e: L_BRKT expr R_BRKT {
    $$ = get_non_term3("", $1, $2, $3);
};

char_: CHAR {
         $$ = str2chr($1);
         };

%%

int main(void)
{
    sym_cnt = 0;
    scope_cnt = 0;
    offset = 0;
    yyparse();
    printf("\n");

    if(p_debug)
        print_symtbl();

    return 0;
}

int yyerror(char *msg)
{
    printf("Error: %s\n", msg);
    exit(1);
}

char* int2chr(int d){
    char *ret = (char*)malloc(sizeof(char)*15);
    sprintf(ret, "%d", d);
    return ret;
}

char* dul2chr(double f){
    char *ret = (char*)malloc(sizeof(char)*20);
    sprintf(ret, "%lf", f);
    return ret;
}


char* str2chr(char *s){
    char *ret = (char*)malloc(sizeof(char)*2);
    ret[1] = '\x00';
    if(strncmp(s+1, "\\n", 2)==0)
        ret[0] = '\n';
    else if(strncmp(s+1, "\\t", 2)==0)
        ret[0] = '\t';
    else if(strncmp(s+1, "\\\\", 2)==0)
        ret[0] = '\\';
    else if(strncmp(s+1, "\\\'", 2)==0)
        ret[0] = '\'';
    else
        ret[0] = s[1];

    free(s);
    return ret;
}

char* get_non_term0(const char *tag){
    int len = 1;
    if(strcmp(tag, "")!=0)
        len += (strlen(tag)*2+5);

    char *ret = (char *)malloc(sizeof(char)*len);

    if(strcmp(tag, "")!=0)
        sprintf(ret, "<%s></%s>", tag, tag);

    ret[len-1] = 0;
    return ret;
}

char *get_non_term1(const char *tag, char *s1){
    int len = strlen(s1)+1;
    if(strcmp(tag, "")!=0)
        len += (strlen(tag)*2+5);

    char *ret = (char *)malloc(sizeof(char)*len);

    if(strcmp(tag, "")!=0)
        sprintf(ret, "<%s>%s</%s>", tag, s1, tag);
    else
        sprintf(ret, "%s", s1);

    free(s1);

    ret[len-1] = 0;
    return ret;
}

char *get_non_term2(const char *tag, char *s1, char *s2){
    int len = strlen(s1)+strlen(s2)+1;
    if(strcmp(tag, "")!=0)
        len += (strlen(tag)*2+5);

    char *ret = (char *)malloc(sizeof(char)*len);

    if(strcmp(tag, "")!=0)
        sprintf(ret, "<%s>%s%s</%s>", tag, s1, s2, tag);
    else
        sprintf(ret, "%s%s", s1, s2);

    free(s1);
    free(s2);

    ret[len-1] = 0;
    return ret;
}

char* get_non_term3(const char *tag, char *s1, char *s2, char *s3){
    int len = strlen(s1)+strlen(s2)+strlen(s3)+1;
    if(strcmp(tag, "")!=0)
        len += (strlen(tag)*2+5);

    char *ret = (char *)malloc(sizeof(char)*len);

    if(strcmp(tag, "")!=0)
        sprintf(ret, "<%s>%s%s%s</%s>", tag, s1, s2, s3, tag);
    else
        sprintf(ret, "%s%s%s", s1, s2, s3);

    free(s1);
    free(s2);
    free(s3);

    ret[len-1] = 0;
    return ret;
}

char* get_non_term4(const char *tag, char *s1, char *s2, char *s3, char *s4){
    int len = strlen(s1)+strlen(s2)+strlen(s3)+strlen(s4)+1;
    if(strcmp(tag, "")!=0)
        len += (strlen(tag)*2+5);

    char *ret = (char *)malloc(sizeof(char)*len);

    if(strcmp(tag, "")!=0)
        sprintf(ret, "<%s>%s%s%s%s</%s>", tag, s1, s2, s3, s4, tag);
    else
        sprintf(ret, "%s%s%s%s", s1, s2, s3, s4);

    free(s1);
    free(s2);
    free(s3);
    free(s4);

    ret[len-1] = 0;
    return ret;
}

char* get_non_term5(const char *tag, char *s1, char *s2, char *s3, char *s4, char *s5){
    int len = strlen(s1)+strlen(s2)+strlen(s3)+strlen(s4)+strlen(s5)+1;
    if(strcmp(tag, "")!=0)
        len += (strlen(tag)*2+5);

    char *ret = (char *)malloc(sizeof(char)*len);

    if(strcmp(tag, "")!=0)
        sprintf(ret, "<%s>%s%s%s%s%s</%s>", tag, s1, s2, s3, s4, s5, tag);
    else
        sprintf(ret, "%s%s%s%s%s", s1, s2, s3, s4, s5);

    free(s1);
    free(s2);
    free(s3);
    free(s4);
    free(s5);

    ret[len-1] = 0;
    return ret;
}

char* get_non_term6(const char *tag, char *s1, char *s2, char *s3, char *s4, char *s5, char *s6){
    int len = strlen(s1)+strlen(s2)+strlen(s3)+strlen(s4)+strlen(s5)+strlen(s6)+1;
    if(strcmp(tag, "")!=0)
        len += (strlen(tag)*2+5);

    char *ret = (char *)malloc(sizeof(char)*len);

    if(strcmp(tag, "")!=0)
        sprintf(ret, "<%s>%s%s%s%s%s%s</%s>", tag, s1, s2, s3, s4, s5, s6, tag);
    else
        sprintf(ret, "%s%s%s%s%s%s", s1, s2, s3, s4, s5, s6);

    free(s1);
    free(s2);
    free(s3);
    free(s4);
    free(s5);
    free(s6);

    ret[len-1] = 0;
    return ret;
}

char* get_non_term7(const char *tag, char *s1, char *s2, char *s3, char *s4, char *s5, char *s6, char *s7){
    int len = strlen(s1)+strlen(s2)+strlen(s3)+strlen(s4)+strlen(s5)+strlen(s6)+strlen(s7)+1;
    if(strcmp(tag, "")!=0)
        len += (strlen(tag)*2+5);

    char *ret = (char *)malloc(sizeof(char)*len);

    if(strcmp(tag, "")!=0)
        sprintf(ret, "<%s>%s%s%s%s%s%s%s</%s>", tag, s1, s2, s3, s4, s5, s6, s7, tag);
    else
        sprintf(ret, "%s%s%s%s%s%s%s", s1, s2, s3, s4, s5, s6, s7);

    free(s1);
    free(s2);
    free(s3);
    free(s4);
    free(s5);
    free(s6);
    free(s7);

    ret[len-1] = 0;
    return ret;
}

/*-------- codegen --------*/

void install_sym(Variant variant, char *name, Type type, int scope, int offset, int mode, int total_args, int total_locals)
{
    if(sym_cnt >= MAX_TABLE_SIZE)
    {
        printf("[-] sym_cnt: %d\n", sym_cnt);
        exit(1);
    }
    
    sym_table[sym_cnt].variant = variant;
    sym_table[sym_cnt].name = name;
    sym_table[sym_cnt].type = type;
    sym_table[sym_cnt].scope = scope;
    sym_table[sym_cnt].offset = offset;
    sym_table[sym_cnt].mode = mode;
    sym_table[sym_cnt].total_args = total_args;
    sym_table[sym_cnt].total_locals = total_locals;

    sym_cnt++;
}

Type str2type(char *s)
{
    if(strcmp(s, "void")==0)
        return T_VOID;
    else if(strcmp(s, "int")==0)
        return T_INT;
    else if(strcmp(s, "double")==0)
        return T_DOUBLE;
    else if(strcmp(s, "float")==0)
        return T_FLOAT;
    else if(strcmp(s, "char")==0)
        return T_CHAR;

    printf("[-] str2type: type %s\n", s);
    exit(1);
}