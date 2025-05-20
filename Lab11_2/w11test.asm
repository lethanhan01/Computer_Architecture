.eqv IN_ADDRESS_HEXA_KEYBOARD   0xFFFF0012  # Address of keyboard
.eqv OUT_ADDRESS_HEXA_KEYBOARD  0xFFFF0014  # Output address of keyboard
.eqv MONITOR_SCREEN             0x10010000  # Start address of display memory

# Bitmap display settings: 32x32, 128x128 pixels
# Each cell will be 8x8 pixels (2x2 words)

# Color constants
.eqv RED                        0x00FF0000

.data 
message:        .asciz "Key scan code: \n"

# --------------------------------------------------------
# MAIN Procedure 
# --------------------------------------------------------
.text 
li  s10, MONITOR_SCREEN 
main: 
    # Load the interrupt service routine address to the UTVEC register 
    la      t0, handler 
    csrrs   zero, utvec, t0 
    
    # Set the UEIE (User External Interrupt Enable) bit in UIE register 
    li      t1, 0x100 
    csrrs   zero, uie, t1       # uie - ueie bit (bit 8) 
    
    # Set the UIE (User Interrupt Enable) bit in USTATUS register 
    csrrsi  zero, ustatus, 1    # ustatus - enable uie (bit 0) 
 
    # Enable the interrupt of keypad of Digital Lab Sim 
    li      t1, IN_ADDRESS_HEXA_KEYBOARD 
    li      t3, 0x80            # bit 7 = 1 to enable interrupt    
    sb      t3, 0(t1)
 
    # --------------------------------------------------------
    # No-end loop, main program
    # --------------------------------------------------------
loop:    
    nop 
    nop 
    nop 
    j       loop 
end_main:

# --------------------------------------------------------
# Draw a colored cell on the bitmap display based on the key code
# a0 - contains the key scan code
# --------------------------------------------------------
draw_cell:
    # Save the context
    addi    sp, sp, -16
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    
    # Map key scan code to grid position based on provided data:
    # Row 1: 0x11(0), 0x21(1), 0x41(2), 0x81(3)
    # Row 2: 0x12(4), 0x22(5), 0x42(6), 0x82(7)
    # Row 3: 0x14(8), 0x24(9), 0x44(10), 0x84(11)
    # Row 4: 0x18(12), 0x28(13), 0x48(14), 0x88(15)
    
    # Calculate position on grid
    li      s0, -1              # Default cell number
    
    # Row 1
    li      t0, 0x11
    beq     a0, t0, cell_0
    li      t0, 0x21
    beq     a0, t0, cell_1
    li      t0, 0x41
    beq     a0, t0, cell_2
    li      t0, 0x81
    beq     a0, t0, cell_3
    
    # Row 2
    li      t0, 0x12
    beq     a0, t0, cell_4
    li      t0, 0x22
    beq     a0, t0, cell_5
    li      t0, 0x42
    beq     a0, t0, cell_6
    li      t0, 0x82
    beq     a0, t0, cell_7
    
    # Row 3
    li      t0, 0x14
    beq     a0, t0, cell_8
    li      t0, 0x24
    beq     a0, t0, cell_9
    li      t0, 0x44
    beq     a0, t0, cell_10
    li      t0, 0x84
    beq     a0, t0, cell_11
    
    # Row 4
    li      t0, 0x18
    beq     a0, t0, cell_12
    li      t0, 0x28
    beq     a0, t0, cell_13
    li      t0, 0x48
    beq     a0, t0, cell_14
    li      t0, 0x88
    beq     a0, t0, cell_15
    
    j       draw_exit           # Invalid key code
    
cell_0:
    li  s9, RED 
    sw  s9, 0(s10)
    j      draw_exit            # Return after drawing the cell
cell_1:
    li  s9, RED 
    sw  s9, 4(s10)
    j      draw_exit            # Return after drawing the cell
cell_2:
    li  s9, RED 
    sw  s9, 8(s10)
    j      draw_exit            # Return after drawing the cell
cell_3:
    li  s9, RED 
    sw  s9, 12(s10)
    j      draw_exit            # Return after drawing the cell
cell_4:
    li  s9, RED 
    sw  s9, 16(s10)
    j      draw_exit            # Return after drawing the cell
cell_5:
    li  s9, RED 
    sw  s9, 20(s10)
    j      draw_exit            # Return after drawing the cell
cell_6:
    li  s9, RED 
    sw  s9, 24(s10)
    j      draw_exit            # Return after drawing the cell
cell_7:
    li  s9, RED 
    sw  s9, 28(s10)
    j      draw_exit            # Return after drawing the cell
cell_8:
    li  s9, RED 
    sw  s9, 32(s10)
    j      draw_exit            # Return after drawing the cell
cell_9:
    li  s9, RED 
    sw  s9, 36(s10)
    j      draw_exit            # Return after drawing the cell
cell_10:
    li  s9, RED 
    sw  s9, 40(s10)
    j      draw_exit            # Return after drawing the cell
cell_11:
    li  s9, RED 
    sw  s9, 44(s10)
    j      draw_exit            # Return after drawing the cell
cell_12:
    li  s9, RED 
    sw  s9, 48(s10)
    j      draw_exit            # Return after drawing the cell
cell_13:
    li  s9, RED 
    sw  s9, 52(s10)
    j      draw_exit            # Return after drawing the cell
cell_14:
    li  s9, RED 
    sw  s9, 56(s10)
    j      draw_exit            # Return after drawing the cell
cell_15:
    li  s9, RED 
    sw  s9, 60(s10)
    j      draw_exit            # Return after drawing the cell
    
draw_exit:
    # Restore the context
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    addi    sp, sp, 16
    jr ra

# --------------------------------------------------------
# Interrupt service routine 
# --------------------------------------------------------
handler: 
    # Save the context
    addi    sp, sp, -24
    sw      ra, 0(sp)
    sw      a0, 4(sp)
    sw      a7, 8(sp)
    sw      t0, 12(sp)
    sw      t1, 16(sp)
    sw      t2, 20(sp)
     
    # Handle the interrupt 
    # Print message
    li      a7, 4      
    la      a0, message 
    ecall
    
    # Get key scan code
    li      t0, IN_ADDRESS_HEXA_KEYBOARD
    li      t2, 0x81      # Check row 1 (0x1) and re-enable interrupt (0x80)
    sb      t2, 0(t0)
    li      t0, OUT_ADDRESS_HEXA_KEYBOARD
    lb      t1, 0(t0)
    bnez    t1, key_found
    
    li      t0, IN_ADDRESS_HEXA_KEYBOARD
    li      t2, 0x82      # Check row 2 (0x2) and re-enable interrupt (0x80)
    sb      t2, 0(t0)
    li      t0, OUT_ADDRESS_HEXA_KEYBOARD
    lb      t1, 0(t0)
    bnez    t1, key_found
    
    li      t0, IN_ADDRESS_HEXA_KEYBOARD
    li      t2, 0x84      # Check row 3 (0x4) and re-enable interrupt (0x80)
    sb      t2, 0(t0)
    li      t0, OUT_ADDRESS_HEXA_KEYBOARD
    lb      t1, 0(t0)
    bnez    t1, key_found
    
    li      t0, IN_ADDRESS_HEXA_KEYBOARD
    li      t2, 0x88      # Check row 4 (0x8) and re-enable interrupt (0x80)
    sb      t2, 0(t0)
    li      t0, OUT_ADDRESS_HEXA_KEYBOARD
    lb      t1, 0(t0)
    
key_found:
    # Print key scan code in hex
    mv      a0, t1          
    li      a7, 34           # Print in hex
    ecall
    
    # Print newline
    li      a7, 11
    li      a0, '\n'
    ecall
    
    # Draw the cell based on the key scan code
    mv      a0, t1           
    jal     draw_cell
     
    # Restore the context
    lw      ra, 0(sp)
    lw      a0, 4(sp)
    lw      a7, 8(sp)
    lw      t0, 12(sp)
    lw      t1, 16(sp)
    lw      t2, 20(sp)
    addi    sp, sp, 24
 
    # Return from the interrupt routine
    uret
