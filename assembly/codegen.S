.global codegen
codegen:
  // BEGIN PROLOGUE
  // codegen is the callee here, so we save callee-saved registers
  sw s0, -4(sp) // save frame pointer
  addi sp, sp, -4
  addi s0, sp, 0 // set new frame
  sw sp, -4(s0)
  sw s1, -8(s0)
  sw s2, -12(s0)
  sw s3, -16(s0)
  sw s4, -20(s0)
  sw s5, -24(s0)
  sw s6, -28(s0)
  sw s7, -32(s0)
  sw s8, -36(s0)
  sw s9, -40(s0)
  sw s10, -44(s0)
  sw s11, -48(s0)
  addi sp, s0, -48 // update stack pointer
  // END PROLOGUE
  li t0, 2147483647
  sw t0, -4(sp)
  addi sp, sp, -4
  li t0, 1
  sw t0, -4(sp)
  addi sp, sp, -4
  lw t1, 0(sp)
  addi sp, sp, 4
  lw t0, 0(sp)
  addi sp, sp, 4
  sub t0, t0, t1
  sw t0, -4(sp)
  addi sp, sp, -4
  li t0, 2147483646
  sw t0, -4(sp)
  addi sp, sp, -4
  lw t1, 0(sp)
  addi sp, sp, 4
  lw t0, 0(sp)
  addi sp, sp, 4
  div t0, t0, t1
  sw t0, -4(sp)
  addi sp, sp, -4
  li t0, 1
  sw t0, -4(sp)
  addi sp, sp, -4
  lw t1, 0(sp)
  addi sp, sp, 4
  lw t0, 0(sp)
  addi sp, sp, 4
  sub t0, t0, t1
  sw t0, -4(sp)
  addi sp, sp, -4
  lw t0, -52(s0)
  sw t0, -4(sp)
  addi sp, sp, -4
  lw t0, 0(sp)
  lw t3, 0(sp)
  addi sp, sp, 4
  li t1, 1
  add t0, t0, t1
  sw t0, -52(s0)
  addi sp, sp, -4
  sw t3, 0(sp)
  lw t0, 0(sp)
  addi sp, sp, 4
  beq t0, zero, if3_0
  li t0, 27
  sw t0, -4(sp)
  addi sp, sp, -4
  li t0, 1
  sw t0, -4(sp)
  addi sp, sp, -4
  lw a1, 0(sp)
  addi sp, sp, 4
  lw a0, 0(sp)
  addi sp, sp, 4
  sw ra, -4(sp)
  addi sp, sp, -4
  jal ra, digitalWrite
  lw ra, 0(sp)
  addi sp, sp, 4
  lw t0, -52(s0)
  sw t0, -4(sp)
  addi sp, sp, -4
  li t0, 1000
  sw t0, -4(sp)
  addi sp, sp, -4
  lw t1, 0(sp)
  addi sp, sp, 4
  lw t0, 0(sp)
  addi sp, sp, 4
  mul t0, t0, t1
  sw t0, -4(sp)
  addi sp, sp, -4
  lw a0, 0(sp)
  addi sp, sp, 4
  sw ra, -4(sp)
  addi sp, sp, -4
  jal ra, delay
  lw ra, 0(sp)
  addi sp, sp, 4
  jal zero, if3_1
if3_0:
  li t0, 27
  sw t0, -4(sp)
  addi sp, sp, -4
  li t0, 1
  sw t0, -4(sp)
  addi sp, sp, -4
  lw a1, 0(sp)
  addi sp, sp, 4
  lw a0, 0(sp)
  addi sp, sp, 4
  sw ra, -4(sp)
  addi sp, sp, -4
  jal ra, digitalWrite
  lw ra, 0(sp)
  addi sp, sp, 4
  lw t0, -52(s0)
  sw t0, -4(sp)
  addi sp, sp, -4
  li t0, 1
  sw t0, -4(sp)
  addi sp, sp, -4
  lw t1, 0(sp)
  addi sp, sp, 4
  lw t0, 0(sp)
  addi sp, sp, 4
  add t0, t0, t1
  sw t0, -4(sp)
  addi sp, sp, -4
  li t0, 3000
  sw t0, -4(sp)
  addi sp, sp, -4
  lw t1, 0(sp)
  addi sp, sp, 4
  lw t0, 0(sp)
  addi sp, sp, 4
  mul t0, t0, t1
  sw t0, -4(sp)
  addi sp, sp, -4
  lw a0, 0(sp)
  addi sp, sp, 4
  sw ra, -4(sp)
  addi sp, sp, -4
  jal ra, delay
  lw ra, 0(sp)
  addi sp, sp, 4
if3_1:
  li t0, 27
  sw t0, -4(sp)
  addi sp, sp, -4
  li t0, 0
  sw t0, -4(sp)
  addi sp, sp, -4
  lw a1, 0(sp)
  addi sp, sp, 4
  lw a0, 0(sp)
  addi sp, sp, 4
  sw ra, -4(sp)
  addi sp, sp, -4
  jal ra, digitalWrite
  lw ra, 0(sp)
  addi sp, sp, 4
  li t0, 2000
  sw t0, -4(sp)
  addi sp, sp, -4
  lw a0, 0(sp)
  addi sp, sp, 4
  sw ra, -4(sp)
  addi sp, sp, -4
  jal ra, delay
  lw ra, 0(sp)
  addi sp, sp, 4
  // BEGIN EPILOGUE
  // restore callee-saved registers
  // s0 at this point should be the same as in prologue
  lw s11, -48(s0)
  lw s10, -44(s0)
  lw s9, -40(s0)
  lw s8, -36(s0)
  lw s7, -32(s0)
  lw s6, -28(s0)
  lw s5, -24(s0)
  lw s4, -20(s0)
  lw s3, -16(s0)
  lw s2, -12(s0)
  lw s1, -8(s0)
  lw sp, -4(s0)
  addi sp, sp, 4
  lw s0, -4(sp)
  // END EPILOGUE

  jalr zero, 0(ra) // return
