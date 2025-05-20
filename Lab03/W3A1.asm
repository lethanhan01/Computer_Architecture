# Laboratory Exercise 3, Home Assignment 1 
.text 
start: 
# TODO: 
# Khởi tạo giá trị i vào thanh ghi s1 
addi s1, zero, 4
# Khởi tạo giá trị j vào thanh ghi s2 
addi s2, zero, 3
# Cách 1: 
blt s2, s1, then   # if j < i then jump then  
then:  
addi  t1, t1, 1   	# then part: x=x+1 
addi  t3, zero, 1  	# z=1 
j   endif             	# skip else part 
else:  
addi  t2, t2, -1        # begin else part: y=y-1 
add   t3, t3, t3        # z=2*z 
endif:
