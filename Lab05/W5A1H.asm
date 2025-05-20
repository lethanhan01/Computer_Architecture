.data
question: .asciz " hello ban nho"
.text 
	li a7, 55
	la a0, question 
	li a1, 0
	ecall