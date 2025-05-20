# Laboratory Exercise 3, Home Assignment 3 
.data 
test: .word 2
.text 
la s0, test    # Nạp địa chỉ của biến test vào s0 
lw s1, 0(s0)   # Nạp giá trị của biến test vào s1 
addi s3, zero, 1
li t0, 0       # Nạp giá trị cần kiểm tra 
li t1, 1       # Nạp giá trị cần kiểm tra 
li t2, 2       # Nạp giá trị cần kiểm tra 
beq s1, t0, case_0 
beq s1, t1, case_1 
beq s1, t2, case_2 
j default 
case_0:  
addi s2, s2, 1 # a = a + 1 
j continue 
case_1:  
sub s2, s2, t1 # a = a - 1 
j continue 
case_2:  
add s3, s3, s3 # b = 2 * b 
j continue 
default:  
continue: