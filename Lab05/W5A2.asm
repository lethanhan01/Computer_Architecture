
.data 
A: .asciz "The sum of "
B: .asciz " and "
C: .asciz " is "
.text 
	li s0, 18	#s0=18
	li s1, 20	#s1=20
	add t1, s0, s1	#t1=s1+s0
	li a7, 4		#a7=4 in ra chuỗi
	la a0, A		#a0 = địa chỉ của chuỗi A
	ecall	
	li a7, 1		#a7=1 in ra số nguyên	
	mv a0, s0	#a0=s0
	ecall
	li a7, 4		#a7=4 in ra chuỗi
	la a0, B		#a0 = địa chỉ của chuỗi B	
	ecall
	li a7, 1		#a7=1 in ra số nguyên	
	mv a0, s1	#a0=s1
	ecall
	li a7, 4		#a7=4 in ra chuỗi
	la a0, C		#a0 = địa chỉ của chuỗi C			
	ecall
	li a7, 1		#a7=1 in ra số nguyên	
	mv a0, t1	#a0=t1
	ecall
