# Laboratory Exercise 5, Home Assignment 3 
.data 
string: .space 50 
message1: .asciz  "Nhap xau: " 
message2: .asciz  "Do dai xau la: " 
.text 
main: 
get_string:
	li a7, 54
	la a0, message1
	la a1, string
	li a2, 50
	ecall 
	# TODO Nhập chuỗi ký tự từ bàn phím 
get_length:  
	la    a0, string        # a0 = address(string[0]) 
	li    t0, 0		# t0 = i = 0 
check_char:  
	add   t1, a0, t0      	# t1 = a0 + t0 = address(string[0]+i)  
	lb    t2, 0(t1)         	# t2 = string[i] 
	beq   t2, zero, end_of_str # Nếu là ký tự NULL thì kết thúc 
	addi  t0, t0, 1       	# t0 = t0 + 1 -> i = i + 1 
	j  check_char 
end_of_str:   
end_of_get_length: 
print_length:
	li a7, 56
	la a0, message2
	mv a1, t0
	ecall
# TODO In kết quả ra màn hình 
