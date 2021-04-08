#include <stdio.h> 
#include <stdlib.h>
#include <string.h>
#include "code.h"

extern FILE *f_asm;
int counter = 0;
int cur_scope   = 1;



void install_symbol(char *s,int cur_mode)
{
  if (counter >= MAX_TABLE_SIZE) printf("Symbol Table Full\n");
  else {
    table[counter].scope = cur_scope;
    strcpy(table[counter].name, s);
    table[counter].mode = cur_mode;
    table[counter].offset = counter;
    counter++;
  }
  return;
}

int look_up_symbol(char *s)
{
   int i;

   if (counter==0) return(-1);
   for (i=counter-1;i>=0; i--)
   {
     if (!strcmp(s,table[i].name))
     return(i);
   }
   return(-1);
}


void pop_up_symbol(int scope)
{
   int i;
   if (counter==0) return;
   
   for (i=counter-1;i>=0; --i)
   {
     if (table[i].scope !=scope) break;
   }
   if (i<0) counter = 0;
   counter = i+1;
}


void code_gen_func_header(char * func)
{
  fprintf(f_asm, "%s:\n", func);
  fprintf(f_asm, "  // BEGIN PROLOGUE\n  // codegen is the callee here, so we save callee-saved registers\n  sw s0, -4(sp) // save frame pointer\n  addi sp, sp, -4\n  addi s0, sp, 0 // set new frame\n  sw sp, -4(s0)\n  sw s1, -8(s0)\n  sw s2, -12(s0)\n  sw s3, -16(s0)\n  sw s4, -20(s0)\n  sw s5, -24(s0)\n  sw s6, -28(s0)\n  sw s7, -32(s0)\n  sw s8, -36(s0)\n  sw s9, -40(s0)\n  sw s10, -44(s0)\n  sw s11, -48(s0)\n  addi sp, s0, -48 // update stack pointer\n  // END PROLOGUE\n");
}


void code_gen_end()
{
  fprintf(f_asm, "  // BEGIN EPILOGUE\n  // restore callee-saved registers\n  // s0 at this point should be the same as in prologue\n  lw s11, -48(s0)\n  lw s10, -44(s0)\n  lw s9, -40(s0)\n  lw s8, -36(s0)\n  lw s7, -32(s0)\n  lw s6, -28(s0)\n  lw s5, -24(s0)\n  lw s4, -20(s0)\n  lw s3, -16(s0)\n  lw s2, -12(s0)\n  lw s1, -8(s0)\n  lw sp, -4(s0)\n  addi sp, sp, 4\n  lw s0, -4(sp)\n  // END EPILOGUE\n\n  jalr zero, 0(ra) // return\n");
}







