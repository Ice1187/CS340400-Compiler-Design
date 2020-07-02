#include <stdio.h>

// data load/store
void asm_sw(char *src, int offset, char *dst)
{
    printf("sw %s, %d(%s)\n", src, offset, dst);
}
void asm_li(char *dst, int num)
{
    printf("li %s, %d\n", dst, num);
}
void asm_lw(char *dst, int offset, char *src)
{
    printf("lw %s, %d(%s)\n", dst, offset, src);
}

// branch
void asm_jal(char *ra, char *fn)
{
    printf("jal %s, %s\n", ra, fn);
}
void asm_jalr(char *ra, int offset, char *fn)
{
    printf("jalr %s, %d(%s)\n", ra, offset, fn);
}

// arithmetic
void asm_addi(char *dst, char *src, int addend)
{
    printf("addi %s, %s, %d\n", dst, src, addend);
}
void asm_add(char *dst, char *src1, char *src2)
{
    printf("add %s, %s, %s\n", dst, src1, src2);
}
void asm_sub(char *dst, char *src1, char *src2)
{
    printf("sub %s, %s, %s\n", dst, src1, src2);
}
void asm_mul(char *dst, char *src1, char *src2)
{
    printf("mul %s, %s, %s\n", dst, src1, src2);
}
void asm_div(char *dst, char *src1, char *src2)
{
    printf("div %s, %s, %s\n", dst, src1, src2);
}
void asm_rem(char *dst, char *src1, char *src2)
{
    printf("rem %s, %s, %s\n", dst, src1, src2);
}
