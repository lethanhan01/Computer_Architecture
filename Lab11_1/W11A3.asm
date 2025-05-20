.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014
.data
message: .asciz "Key scan code: "
# -----------------------------------------------------------------
# MAIN Procedure
# -----------------------------------------------------------------
.text
main:
	# Load the interrupt service routine address to the UTVEC register
	la t0, handler
	csrrs zero, utvec, t0
	# Set the UEIE (User External Interrupt Enable) bit in UIE register
	li t1, 0x100
	csrrs zero, uie, t1 # uie - ueie bit (bit
	# Set the UIE (User Interrupt Enable) bit in USTATUS register
	csrrsi zero, ustatus, 1 # ustatus - enable uie (bit 0)
	# Enable the interrupt of keypad of Digital Lab Sim
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t3, 0x80 # bit 7 = 1 to enable interrupt
	sb t3, 0(t1)
	# ---------------------------------------------------------
	# Loop to print a sequence numbers
	# ---------------------------------------------------------
	xor s0, s0, s0 # count = s0 = 0
loop:
	addi s0, s0, 1 # count = count + 1
prn_seq:
	addi a7, zero, 1
	add a0, s0, zero # Print auto sequence number
	ecall
	addi a7, zero, 11
	li a0, '\n' # Print EOL
	ecall
sleep:
	addi a7, zero, 32
	li a0, 300 # Sleep 300 ms
	ecall
	j loop
end_main:
# -----------------------------------------------------------------
# Interrupt service routine
# -----------------------------------------------------------------
handler:# Saves the context
	addi sp, sp, -16
	sw a0, 0(sp)
	sw a7, 4(sp)
	sw t1, 8(sp)
	sw t2, 12(sp)
	# Handles the interrupt
prn_msg:
	addi a7, zero, 4
	la a0, message
	ecall
get_key_code:
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li a0, 0
check_row_1:
	li t2, 0x81 # Check row 4 and re-enable bit 7
	sb t2, 0(t1) # Must reassign expected row
	li t1, OUT_ADDRESS_HEXA_KEYBOARD
	lb a0, 0(t1)
	bne a0, zero, prn_key_code
check_row_2:
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t2, 0x82
	sb t2, 0(t1)
	li t1, OUT_ADDRESS_HEXA_KEYBOARD
	lb a0, 0(t1)
	bne a0, zero, prn_key_code
check_row_3:
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t2, 0x84
	sb t2, 0(t1)
	li t1, OUT_ADDRESS_HEXA_KEYBOARD
	lb a0, 0(t1)
	bne a0, zero, prn_key_code
check_row_4:
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t2, 0x88
	sb t2, 0(t1)
	li t1, OUT_ADDRESS_HEXA_KEYBOARD
	lb a0, 0(t1)
	bne a0, zero, prn_key_code
prn_key_code:
	li a7, 34
	ecall
	li a7, 11
	li a0, '\n' # Print EOL
	ecall
	# Restores the context
	lw t2, 12(sp)
	lw t1, 8(sp)
	lw a7, 4(sp)
	lw a0, 0(sp)
	addi sp, sp, 16
	# Back to the main procedure
	uret


