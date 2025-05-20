# Laboratory Exercise 3, Home Assignment 1 
.text 
start: 
# TODO: 
# Khởi tạo giá trị i vào thanh ghi s1 
addi s1, zero, 2
# Khởi tạo giá trị j vào thanh ghi s2 
addi s2, zero, 3
addi s3, s3, 4
addi s4, s4, 0
add s5, s1, s2
add s6, s4, s3
bge s6, s5, else
     
then:  
addi  t1, t1, 1   	# then part: x=x+1 
addi  t3, zero, 1  	# z=1 
j   endif             	# skip else part 
else:  
addi  t2, t2, -1        # begin else part: y=y-1 
add   t3, t3, t3        # z=2*z 
endif:
