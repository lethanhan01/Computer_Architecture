.text
	addi s0, s0, 1234	
	sub s1, zero, s0		#s1 =-s0
	add s2, x0, s0		#s2=s0
	xori s3, s0, -1		#s3=not(s0)
	bge s2, s1, LABEL	#thay the lenh ble bang bge
LABEL: