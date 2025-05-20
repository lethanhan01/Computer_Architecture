# RISC-V Program: Counter with Timer and Keypad
# Displays a counter (00-99) on two 7-segment displays
# Controls:
#   Button 0: Count up mode
#   Button 1: Count down mode
#   Button 4: Decrease cycle (increase speed)
#   Button 5: Increase cycle (decrease speed)

# Memory-mapped I/O addresses
.eqv IN_ADDRESS_HEXA_KEYBOARD   0xFFFF0012  # Input from hexadecimal keyboard
.eqv OUT_ADDRESS_HEXA_KEYBOARD  0xFFFF0014  # Output from hexadecimal keyboard
.eqv TIMER_NOW                  0xFFFF0018  # Current time
.eqv TIMER_CMP                  0xFFFF0020  # Time for next interrupt
.eqv MASK_CAUSE_TIMER           4           # Timer interrupt cause code
.eqv MASK_CAUSE_KEYPAD          8           # Keyboard interrupt cause code
.eqv SEVENSEG_LEFT              0xFFFF0011  # Left 7-segment display
.eqv SEVENSEG_RIGHT             0xFFFF0010  # Right 7-segment display

.data
# Configuration and state variables
count:         .word 0        # Current counter value (0-99)
count_mode:    .word 0        # 0: count up, 1: count down
cycle_time:    .word 1000     # Initial cycle time

# 7-segment display codes for digits 0-9
seg_codes:     .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F

# Debug messages
msg_keypad:    .asciz "Keypad button pressed: "
msg_key_code:  .asciz "Key scan code: 0x"
msg_timer:     .asciz "Timer event! Count: "
msg_mode_up:   .asciz "Mode changed: Count Up\n"
msg_mode_down: .asciz "Mode changed: Count Down\n"
msg_cycle_inc: .asciz "Cycle time increased to: "
msg_cycle_dec: .asciz "Cycle time decreased to: "
newline:       .asciz "\n"

.text
main:
    # Set up the interrupt handler
    la      t0, handler
    csrrs   zero, utvec, t0
    
    # Enable external and timer interrupts
    li      t1, 0x100         # External interrupt enable (bit 8)
    csrrs   zero, uie, t1
    csrrsi  zero, uie, 0x10   # Timer interrupt enable (bit 4)
    
    # Enable global interrupts
    csrrsi  zero, ustatus, 1
    
    # Enable keypad interrupt
    li      t1, IN_ADDRESS_HEXA_KEYBOARD
    li      t2, 0x80          # Bit 7 = 1 to enable interrupt
    sb      t2, 0(t1)
    
    # Set initial timer comparison value
    li      t1, TIMER_NOW
    lw      t2, 0(t1)         # Get current time
    la      t3, cycle_time
    lw      t3, 0(t3)
    add     t2, t2, t3        # Add cycle time
    li      t1, TIMER_CMP
    sw      t2, 0(t1)         # Set comparison value
    
    # Initialize display
    jal     update_display
    
    # Main loop - do nothing, interrupts handle everything
loop:
    nop
    j       loop

# ---------------------------------------------------------------
# Interrupt Service Routine
# ---------------------------------------------------------------
handler:
    # Save context
    addi    sp, sp, -28
    sw      ra, 0(sp)
    sw      a0, 4(sp)
    sw      a1, 8(sp)
    sw      a2, 12(sp)
    sw      t0, 16(sp)
    sw      t1, 20(sp)
    sw      a7, 24(sp)
    
    # Get interrupt cause
    csrr    a1, ucause
    li      a2, 0x7FFFFFFF
    and     a1, a1, a2      # Clear MSB to get cause value
    
    # Check interrupt type
    li      a2, MASK_CAUSE_TIMER
    beq     a1, a2, timer_isr
    li      a2, MASK_CAUSE_KEYPAD
    beq     a1, a2, keypad_isr
    j       end_handler
    
timer_isr:
    # Handle timer interrupt - update counter
    la      t1, count_mode
    lw      t0, 0(t1)
    bnez    t0, count_down    # If mode is 1, count down
    
count_up:
    la      t1, count
    lw      t0, 0(t1)
    addi    t0, t0, 1        # Increment counter
    li      t1, 100
    rem     t0, t0, t1       # Keep in range 0-99
    la      t1, count
    sw      t0, 0(t1)
    j       timer_continue
    
count_down:
    la      t1, count
    lw      t0, 0(t1)
    addi    t0, t0, -1       # Decrement counter
    bltz    t0, wrap_to_99   # If negative, wrap to 99
    la      t1, count
    sw      t0, 0(t1)
    j       timer_continue
    
wrap_to_99:
    li      t0, 99
    la      t1, count
    sw      t0, 0(t1)
    
timer_continue:
    # Update display
    jal     update_display
    
    # Set next timer interrupt
    li      a0, TIMER_NOW
    lw      a1, 0(a0)        # Get current time
    la      t1, cycle_time
    lw      t0, 0(t1)
    add     a1, a1, t0       # Add cycle time
    li      a0, TIMER_CMP
    sw      a1, 0(a0)        # Set new comparison value
    
    j       end_handler
    
keypad_isr:
    # Get key scan code by scanning each row
    # First row
    li      t0, IN_ADDRESS_HEXA_KEYBOARD
    li      t2, 0x81          # Check row 1 (0x1) and re-enable interrupt (0x80)
    sb      t2, 0(t0)
    li      t0, OUT_ADDRESS_HEXA_KEYBOARD
    lb      t1, 0(t0)
    bnez    t1, process_key
    
    # Second row
    li      t0, IN_ADDRESS_HEXA_KEYBOARD
    li      t2, 0x82          # Check row 2 (0x2) and re-enable interrupt (0x80)
    sb      t2, 0(t0)
    li      t0, OUT_ADDRESS_HEXA_KEYBOARD
    lb      t1, 0(t0)
    bnez    t1, process_key
    
    # Third row
    li      t0, IN_ADDRESS_HEXA_KEYBOARD
    li      t2, 0x84          # Check row 3 (0x4) and re-enable interrupt (0x80)
    sb      t2, 0(t0)
    li      t0, OUT_ADDRESS_HEXA_KEYBOARD
    lb      t1, 0(t0)
    bnez    t1, process_key
    
    # Fourth row
    li      t0, IN_ADDRESS_HEXA_KEYBOARD
    li      t2, 0x88          # Check row 4 (0x8) and re-enable interrupt (0x80)
    sb      t2, 0(t0)
    li      t0, OUT_ADDRESS_HEXA_KEYBOARD
    lb      t1, 0(t0)
    beqz    t1, end_handler   # No key pressed, exit
    
process_key:
    # Print key scan code
    li      a7, 4
    la      a0, msg_key_code
    ecall
    mv      a0, t1
    li      a7, 34           # Print in hex
    ecall
    li      a7, 4
    la      a0, newline
    ecall

    # Map scan code to button number
    # Row 1: 0x11(0), 0x21(1), 0x41(2), 0x81(3)
    # Row 2: 0x12(4), 0x22(5), 0x42(6), 0x82(7)
    # Row 3: 0x14(8), 0x24(9), 0x44(10), 0x84(11)
    # Row 4: 0x18(12), 0x28(13), 0x48(14), 0x88(15)
    
    # Check row 1 keys
    li      t0, 0x11
    beq     t1, t0, key_0
    li      t0, 0x21
    beq     t1, t0, key_1
    li      t0, 0x41
    beq     t1, t0, end_handler  # Key 2 - not used
    li      t0, 0x81
    beq     t1, t0, end_handler  # Key 3 - not used
    
    # Check row 2 keys
    li      t0, 0x12
    beq     t1, t0, key_4
    li      t0, 0x22
    beq     t1, t0, key_5
    li      t0, 0x42
    beq     t1, t0, end_handler  # Key 6 - not used
    li      t0, 0x82
    beq     t1, t0, end_handler  # Key 7 - not used
    
    # Other keys not used in this program
    j       end_handler
    
key_0:  # Set count up mode
    li      t0, 0
    la      t1, count_mode
    sw      t0, 0(t1)
    
    # Debug message
    li      a7, 4
    la      a0, msg_mode_up
    ecall
    
    j       end_handler
    
key_1:  # Set count down mode
    li      t0, 1
    la      t1, count_mode
    sw      t0, 0(t1)
    
    # Debug message
    li      a7, 4
    la      a0, msg_mode_down
    ecall
    
    j       end_handler
    
key_4:  # Decrease cycle time (minimum 100)
    la      t1, cycle_time
    lw      t0, 0(t1)
    addi    t0, t0, -100     # Decrease by 100
    li      t2, 100
    blt     t0, t2, set_min_cycle
    sw      t0, 0(t1)
    
    # Debug message
    li      a7, 4
    la      a0, msg_cycle_dec
    ecall
    li      a7, 1
    mv      a0, t0
    ecall
    li      a7, 4
    la      a0, newline
    ecall
    
    j       end_handler
    
set_min_cycle:
    li      t0, 100
    la      t1, cycle_time
    sw      t0, 0(t1)
    
    # Debug message
    li      a7, 4
    la      a0, msg_cycle_dec
    ecall
    li      a7, 1
    li      a0, 100
    ecall
    li      a7, 4
    la      a0, newline
    ecall
    
    j       end_handler
    
key_5:  # Increase cycle time (maximum 3000)
    la      t1, cycle_time
    lw      t0, 0(t1)
    addi    t0, t0, 100      # Increase by 100
    li      t2, 3000
    bgt     t0, t2, set_max_cycle
    sw      t0, 0(t1)
    
    # Debug message
    li      a7, 4
    la      a0, msg_cycle_inc
    ecall
    li      a7, 1
    mv      a0, t0
    ecall
    li      a7, 4
    la      a0, newline
    ecall
    
    j       end_handler
    
set_max_cycle:
    li      t0, 3000
    la      t1, cycle_time
    sw      t0, 0(t1)
    
    # Debug message
    li      a7, 4
    la      a0, msg_cycle_inc
    ecall
    li      a7, 1
    li      a0, 3000
    ecall
    li      a7, 4
    la      a0, newline
    ecall
    
end_handler:
    # Re-enable keyboard interrupt
    li      t0, IN_ADDRESS_HEXA_KEYBOARD
    li      t1, 0x80          # Set bit 7 to enable interrupt
    sb      t1, 0(t0)
    
    # Restore context
    lw      ra, 0(sp)
    lw      a0, 4(sp)
    lw      a1, 8(sp)
    lw      a2, 12(sp)
    lw      t0, 16(sp)
    lw      t1, 20(sp)
    lw      a7, 24(sp)
    addi    sp, sp, 28
    uret

# ---------------------------------------------------------------
# Function: update_display
# Updates both 7-segment displays with the current counter value
# ---------------------------------------------------------------
update_display:
    # Save context
    addi    sp, sp, -16
    sw      ra, 0(sp)
    sw      t0, 4(sp)
    sw      t1, 8(sp)
    sw      t2, 12(sp)
    
    # Get counter value
    la      t1, count
    lw      t0, 0(t1)
    
    # Calculate tens digit
    li      t1, 10
    div     t2, t0, t1       # t2 = tens digit
    
    # Get segment code for tens digit
    la      t1, seg_codes
    add     t1, t1, t2
    lb      a0, 0(t1)
    
    # Display tens digit on left display
    jal     SHOW_7SEG_LEFT
    
    # Calculate ones digit
    la      t1, count
    lw      t0, 0(t1)
    li      t1, 10
    rem     t2, t0, t1       # t2 = ones digit
    
    # Get segment code for ones digit
    la      t1, seg_codes
    add     t1, t1, t2
    lb      a0, 0(t1)
    
    # Display ones digit on right display
    jal     SHOW_7SEG_RIGHT
    
    # Restore context
    lw      ra, 0(sp)
    lw      t0, 4(sp)
    lw      t1, 8(sp)
    lw      t2, 12(sp)
    addi    sp, sp, 16
    jr      ra

# ---------------------------------------------------------------
# Function: SHOW_7SEG_LEFT
# Displays a value on the left 7-segment display
# param[in] a0: value to show
# ---------------------------------------------------------------
SHOW_7SEG_LEFT:
    li      t0, SEVENSEG_LEFT
    sb      a0, 0(t0)
    jr      ra

# ---------------------------------------------------------------
# Function: SHOW_7SEG_RIGHT
# Displays a value on the right 7-segment display
# param[in] a0: value to show
# ---------------------------------------------------------------
SHOW_7SEG_RIGHT:
    li      t0, SEVENSEG_RIGHT
    sb      a0, 0(t0)
    jr      ra