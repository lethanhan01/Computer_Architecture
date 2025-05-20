.text
	addi s0, s0, 5
	addi s1, s1, 4
	addi t0, t0, 0	#i=0
	addi t1, t1, 1	#step =1
	addi s3, s3, 2	#s3=2
	mul t3, s0, s1
loop:
	blt s1, s3, continue
	div s1, s1, s3
	add t1, t1, t2
	j loop
continue:
	sll s3, s0, t1 #s3=s1*s0
