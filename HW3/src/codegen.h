#include <stdio.h>
#include <string.h>
#include "asm.h"

#define MAX_TABLE_SIZE 500

typedef enum
{
    V_ARG,
    V_FN,
    V_VAR
} Variant;

typedef enum
{
    T_VOID,
    T_INT,
    T_DOUBLE,
    T_FLOAT,
    T_CHAR
} Type;

struct sym_entry
{
    Variant variant;  // Variant
    char *name;       // symbol name
    Type type;        // type of the symbol
    int scope;        // scope
    int offset;       // i'th arg, j'th local, k'th ...
    int mode;         // local var: 0, global var 1
    int total_args;   // function specify
    int total_locals; // function specify
} sym_table[MAX_TABLE_SIZE];

int sym_cnt = 0;
int get_sym_idx(char *name);
void print_symtbl();

void cg_fn_prologue()
{
    asm_sw("s0", -4, "sp");
    asm_addi("sp", "sp", -4);
    asm_addi("s0", "sp", 0); // set new frame
    asm_sw("sp", -4, "s0");
    asm_sw("s1", -8, "s0");
    asm_sw("s2", -12, "s0");
    asm_sw("s3", -16, "s0");
    asm_sw("s4", -20, "s0");
    asm_sw("s5", -24, "s0");
    asm_sw("s6", -28, "s0");
    asm_sw("s7", -32, "s0");
    asm_sw("s8", -36, "s0");
    asm_sw("s9", -40, "s0");
    asm_sw("s10", -44, "s0");
    asm_sw("s11", -48, "s0");
    asm_addi("sp", "s0", -48);
}

void cg_fn_epilogue()
{
    asm_lw("s11", -48, "s0");
    asm_lw("s10", -44, "s0");
    asm_lw("s9", -40, "s0");
    asm_lw("s8", -36, "s0");
    asm_lw("s7", -32, "s0");
    asm_lw("s6", -28, "s0");
    asm_lw("s5", -24, "s0");
    asm_lw("s4", -20, "s0");
    asm_lw("s3", -16, "s0");
    asm_lw("s2", -12, "s0");
    asm_lw("s1", -8, "s0");
    asm_lw("sp", -4, "s0");
    asm_addi("sp", "sp", 4);
    asm_lw("s0", -4, "sp");
    asm_jalr("zero", 0, "ra");
}

void cg_dwrite(int pin, int level)
{
    asm_sw("ra", -4, "sp");
    asm_addi("sp", "sp", -4);
    asm_li("a0", pin);
    asm_li("a1", level);
    asm_jal("ra", "digitalWrite");
    asm_lw("ra", 0, "sp");
    asm_addi("sp", "sp", 4);
}

void cg_delay()
{
    asm_lw("a0", 0, "sp");
    asm_sw("ra", -4, "sp");
    asm_addi("sp", "sp", -4);
    // asm_li("a0", ms);
    asm_jal("ra", "delay");
    asm_lw("ra", 0, "sp");
    asm_addi("sp", "sp", 4);
}

void cg_fn_decl_by_name(char *name)
{
    printf(".global %s\n", name);
}

void cg_fn_start(char *label)
{
    printf("%s:\n", label);
    cg_fn_prologue();
}

void cg_fn_end()
{
    cg_fn_epilogue();
}

void cg_store_var(int offset)
{
    asm_lw("t0", 0, "sp");
    asm_sw("t0", -(48 + offset * 4), "s0");
}

void cg_get_var(char *name)
{
    struct sym_entry sym = sym_table[get_sym_idx(name)];
    asm_lw("t0", -(48 + sym.offset * 4), "s0");
    asm_sw("t0", -4, "sp");
    asm_addi("sp", "sp", -4);
}

void cg_bin_op(char *op)
{
    asm_lw("t1", 0, "sp");
    asm_addi("sp", "sp", 4);
    asm_lw("t0", 0, "sp");
    asm_addi("sp", "sp", 4);

    if (strcmp(op, "+") == 0)
        asm_add("t0", "t0", "t1");
    else if (strcmp(op, "-") == 0)
        asm_sub("t0", "t0", "t1");
    else if (strcmp(op, "*") == 0)
        asm_mul("t0", "t0", "t1");
    else if (strcmp(op, "/") == 0)
        asm_div("t0", "t0", "t1");
    else if (strcmp(op, "%") == 0)
        asm_rem("t0", "t0", "t1");

    asm_sw("t0", -4, "sp");
    asm_addi("sp", "sp", -4);
}

// trivial
void cg_constant_int(int num)
{
    asm_li("t0", num);
    asm_sw("t0", -4, "sp");
    asm_addi("sp", "sp", -4);
}

// void cg_fn_def_by_name(char *fn)
// {
//     struct sym_entry sym = sym_table[get_sym_idx(fn)];
//     printf("%s:\n", sym.name);
//     cg_fn_prologue();
//     cg_fn_epilogue();
// }

/*-------- tools --------*/

int get_sym_idx(char *name)
{
    int cnt = 0;
    while (cnt < sym_cnt)
    {
        if (strcmp(sym_table[cnt].name, name) == 0)
            return cnt;
        cnt++;
    }

    return -1;
}

void print_symtbl()
{
    int cnt = 0;
    while (cnt < sym_cnt)
    {
        printf("%d: %s\n", cnt, sym_table[cnt].name);
        cnt++;
    }
}