.data
msg_largest:  .asciz "Largest: " 
msg_smallest: .asciz "Smallest: " 
msg_comma:    .asciz ", " 
newline:      
.text 
.asciz "\n" 
.globl main 
main: 
# Nạp 8 số nguyên vào các thanh ghi a0 – a7 
li a0, 5 
li a1, 11 
li a2, 8 
li a3, 10 
li a4, 0 
li a5, 3 
li a6, -4 
li a7, -43 
# Đẩy 8 số lên ngăn xếp (32 byte: 8 x 4) 
addi sp, sp, -32
	sw a0, 0(sp)
	sw a1, 4(sp)
	sw a2, 8(sp)
	sw a3, 12(sp)
	sw a4, 16(sp)
	
	