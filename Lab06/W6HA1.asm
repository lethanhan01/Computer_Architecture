.data 
A: .word -2, 4, -1, 5, -2, 3, 4, -7 
.text 
main:  
   la    a0, A 
   li    a1, 8 
   j     mspfx 
continue: 
exit:  
   li    a7, 10 
   ecall 
end_of_main: 
 
# ----------------------------------------------------------------- 
# Procedure mspfx 
# @brief find the maximum-sum prefix in a list of integers 
# @param[in] a0 the base address of this list(A) needs to be processed 
# @param[in] a1 the number of elements in list(A)  
# @param[out] s0 the length of sub-array of A in which max sum reachs. 
# @param[out] s1 the max sum of a certain sub-array 
# ----------------------------------------------------------------- 
# Procedure mspfx 
# Function: find the maximum-sum prefix in a list of integers 
# The base address of this list(A) in a0 and the number of 
# elements is stored in a1 
 
mspfx:  
   li    s0, 0          # initialize length of prefix-sum in s0 to 0 
   li    s1, 0x80000000 # initialize max prefix-sum in s1 to smallest int  
   li    t0, 0          # initialize index for loop i in t0 to 0 
   li    t1, 0          # initialize running sum in t1 to 0 
loop:  
   add   t2, t0, t0     # put 2i in t2 
   add   t2, t2, t2     # put 4i in t2 
   add   t3, t2, a0     # put 4i+A (address of A[i]) in t3 
   lw    t4, 0(t3)      # load A[i] from mem(t3) into t4 
   add   t1, t1, t4     # add A[i] to running sum in t1 
   blt   s1, t1, mdfy   # if (s1 < t1) modify results 
   j     next            
mdfy:  
   addi  s0, t0, 1      # new max-sum prefix has length i+1 
   addi  s1, t1, 0      # new max sum is the running sum 
next:  
   addi  t0, t0, 1      # advance the index i 
   blt   t0, a1, loop   # if (i<n) repeat 
done:  
   j     continue 
mspfx_end: 
