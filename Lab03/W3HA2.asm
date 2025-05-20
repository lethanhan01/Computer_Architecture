# Laboratory 3, Home Assigment 2 
.data 
A: .word 10, 0, 1 
.text 
# TODO: Khởi tạo giá trị các thanh ghi s2, s3, s4 
la s2, A
addi s3, zero, 3
addi s4, zero, 1
li s1, 0 	#i = 0
li s5, 0 	#sum = 0
loop:  
add t1, s1, s1    # t1 = 2 * s1 
add t1, t1, t1    # t1 = 4 * s1 => t1 = 4*i 
add t1, t1, s2    # t1 store the address of A[i] 
lw  t0, 0(t1)     # load value of A[i] in t0 
beq t0, zero, endloop # if A[i]==0 then end loop 
add s5, s5, t0    # sum = sum + A[i] 
add s1, s1, s4    # i = i + step 
j  loop           # go to loop 
endloop:
