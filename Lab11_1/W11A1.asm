# ------------------------------------------------------ 
# 		col 0x1 	col 0x2 	col 0x4 	col 0x8  
# row 0x1 	0 	1 	2 	3  
# 		0x11 	0x21 	0x41 	0x81  
# row 0x2 	4 	5 	6 	7 
# 		0x12 	0x22 	0x42 	0x82 
# row 0x4 	8 	9 	a 	b  
# 		0x14 	0x24 	0x44 	0x84 
# row 0x8 	c 	d 	e 	f 
# 		0x18 	0x28 	0x48 	0x88 
# ------------------------------------------------------ 
# Command row number of hexadecimal keyboard (bit 0 to 3) 
# Eg. assign 0x1, to get key button 0,1,2,3 
# assign 0x2, to get key button 4,5,6,7 
# NOTE must reassign value for this address before reading, 
# eventhough you only want to scan 1 row 
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012 
# Receive row and column of the key pressed, 0 if not key pressed  
# Eg. equal 0x11, means that key button 0 pressed. 
# Eg. equal 0x28, means that key button D pressed. 
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014 
.data 
A: .asciz "\n"
.text 
main: 
li t1, IN_ADDRESS_HEXA_KEYBOARD 
li t2, OUT_ADDRESS_HEXA_KEYBOARD 
li t3, 0x01 # start with row 1 (0x01) 
polling: 
print: 
# Check current row 
sb t3, 0(t1)          
lb a0, 0(t2)         
# set the row to scan 
 # read scan code of key button 
# Only print if a key is pressed (a0 != 0) 
beqz a0, slow_down    # if no key pressed, skip print 
li a7, 34             
ecall 
# print integer (hexa) 
# Print space for readability 
li a0, 32             
li a7, 11 
ecall 
slow_down: 
li a7, 4
la a0, A
ecall
next_row: 
 # sleep 300ms - longer delay to keep execution speed under control 
# Rotate through rows in sequence: 0x01 -> 0x02 -> 0x04 -> 0x08 -> 0x01 
 li t4, 0x01 
 beq t3, t4, set_row_2 
 li t4, 0x02 
 beq t3, t4, set_row_4 
 li t4, 0x04 
 beq t3, t4, set_row_8 
 li t4, 0x08 
 beq t3, t4, set_row_1 
  
 # Fallback (shouldn't reach here) 
 li t3, 0x01 
 j polling 
  
set_row_1: 
 li t3, 0x01 
 j polling 
  
set_row_2: 
 li t3, 0x02 
 j polling 
  
set_row_4: 
 li t3, 0x04 
 j polling 
  
set_row_8: 
 li t3, 0x08 
 j polling
