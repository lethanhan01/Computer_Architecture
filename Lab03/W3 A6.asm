.data
	A: .word 10, 2, -11, 4, 7, 8
.text
	addi s1, zero, 6	 	# n = 6
	addi s2, s2, 0 		# i = 0
	la s3, A 		# s3 luu dia chi cua A
	addi s4, s4, -50 	# gia tri max
loop:
	bge s2, s1, endloop	# 1 >= n then endloop
	add t1, s2,s2
	add t1, t1, t1 		# 4*i
	add t1, t1, s3 		# luu dia chi cua phan tu tiep theo
	lw t0, 0(t1) 		# luu gia tri cua phan tu tiep
	blt t0, zero, negative 	# neu gia tri am
continue:
	blt s4, t0, max
tiep:
	addi s2, s2, 1
	j loop
negative:
	sub t0, zero, t0
	j continue
max:
	add s4, zero, t0
	j tiep
endloop: