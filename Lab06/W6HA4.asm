# Laboratory Exercise 7, Home Assignment 4 
.data 
message: .asciz  "Ket qua tinh giai thua la: " 
.text 
main: 
	jal    WARP 
print: 
	add    a1, s0, zero     # a0 = result from N! 
	li     a7, 56 
	la     a0, message 
	ecall 
quit: 
	li     a7, 10           # terminate 
	ecall       
end_main: 
# ---------------------------------------------------------------------- 
# Procedure WARP: assign value and call FACT   
# ---------------------------------------------------------------------- 
WARP: 
    addi   sp, sp, -4   # adjust stack pointer 
    sw     ra, 0(sp)    # save return address 
 
    li     a0, 3        # load test input N 
    jal    FACT         # call fact procedure              
        
    lw     ra, 0(sp)    # restore return address 
    addi   sp, sp, 4    # return stack pointer 
    jr     ra                             
wrap_end: 
 
# ---------------------------------------------------------------------- 
# Procedure FACT: compute N! 
# param[in]  a0  integer N 
# return     s0   the largest value 
# ---------------------------------------------------------------------- 
FACT: 
    addi    sp, sp, -8  # allocate space for ra, a0 in stack   
    sw      ra, 4(sp)   # save ra register 
    sw      a0, 0(sp)   # save a0 register 
 
    li      t0, 2 
    bge     a0, t0, recursive 
    li      s0, 1       # return the result N!=1 
    j       done 
recursive: 
    addi    a0, a0, -1  # adjust input argument 
    jal     FACT        # recursive call   
    lw      s1, 0(sp)   # load a0 
    mul     s0, s0, s1 
done: 
    lw      ra, 4(sp)   # restore ra register 
    lw      a0, 0(sp)   # restore a0 register 
    addi    sp,sp,8     # restore stack pointer 
    jr      ra          # jump to caller 
fact_end: 