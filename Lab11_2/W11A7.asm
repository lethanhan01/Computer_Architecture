# RISC-V Assembly (RARS 1.6 compatible)
# File: keypad_timer_interrupt.s

.eqv IN_ADDRESS_HEXA_KEYBOARD   0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD  0xFFFF0014
.eqv MONITOR_SCREEN             0x10010000
.eqv TIMER_CTRL                 0xFFFF0018
.eqv TIMER_COUNTER              0xFFFF001C
.eqv LED7SEG_ADDRESS            0xFFFF0020

.eqv RED                        0x00FF0000
.eqv CYCLE_DEFAULT              1000

.data
message:        .asciz "Key scan code: \n"

.text
.globl main

main:
    li      s10, MONITOR_SCREEN
    li      s3, CYCLE_DEFAULT     # Initial cycle
    li      s2, 0                 # Initial count value
    li      s1, 1                 # Counting direction (1: up, -1: down)

    la      t0, handler
    csrrw   zero, utvec, t0

    li      t1, 0x100
    csrrs   zero, uie, t1
    csrrsi  zero, ustatus, 1

    li      t1, IN_ADDRESS_HEXA_KEYBOARD
    li      t3, 0x80
    sb      t3, 0(t1)

    # Timer interrupt enable
    li      t1, TIMER_CTRL
    li      t2, 1
    sw      t2, 0(t1)             # Enable timer compare interrupt

    # Set initial counter
    li      t1, TIMER_COUNTER
    li      t2, CYCLE_DEFAULT
    sw      t2, 0(t1)

loop:
    nop
    j       loop

handler:
    addi    sp, sp, -32
    sw      ra, 0(sp)
    sw      a0, 4(sp)
    sw      a7, 8(sp)
    sw      t0, 12(sp)
    sw      t1, 16(sp)
    sw      t2, 20(sp)
    sw      t3, 24(sp)
    sw      t4, 28(sp)

    # Check keypad input
    li      t0, IN_ADDRESS_HEXA_KEYBOARD
    li      t3, 0x81
    sb      t3, 0(t0)
    li      t0, OUT_ADDRESS_HEXA_KEYBOARD
    lb      t1, 0(t0)
    bnez    t1, handle_key

    # Check timer interrupt (happens if key not pressed)
    li      t0, TIMER_CTRL
    lw      t1, 0(t0)
    andi    t2, t1, 1
    beqz    t2, end_handler

    # Timer interrupt, update count
    add     s2, s2, s1
    li      t3, 100
    rem     t4, s2, t3            # Ensure stays within 0..99
    bltz    t4, reset_to_zero
    mv      s2, t4
    j       show_count

reset_to_zero:
    li      s2, 0

show_count:
    mv      t0, s2
    li      t1, 10
    div     t2, t0, t1            # High digit
    rem     t3, t0, t1            # Low digit
    slli    t2, t2, 4
    or      t2, t2, t3
    li      t1, LED7SEG_ADDRESS
    sb      t2, 0(t1)

    # Reset timer
    li      t0, TIMER_COUNTER
    mv      t1, s3
    sw      t1, 0(t0)
    j       end_handler

handle_key:
    li      a0, 4
    la      a0, message
    li      a7, 4
    ecall

    mv      a0, t1
    li      a7, 34
    ecall

    li      a7, 11
    li      a0, '\n'
    ecall

    # Draw and act based on key
    mv      a0, t1
    jal     draw_cell

    li      t2, 0x44
    beq     t1, t2, set_count_up   # Key 0
    li      t2, 0x84
    beq     t1, t2, set_count_down # Key 1
    li      t2, 0x14
    beq     t1, t2, speed_up       # Key 4
    li      t2, 0x24
    beq     t1, t2, slow_down      # Key 5
    j       end_handler

set_count_up:
    li      s1, 1
    j       end_handler

set_count_down:
    li      s1, -1
    j       end_handler

speed_up:
    li      t3, 10
    div     s3, s3, t3
    j       end_handler

slow_down:
    li      t3, 10
    mul     s3, s3, t3
    j       end_handler

end_handler:
    lw      ra, 0(sp)
    lw      a0, 4(sp)
    lw      a7, 8(sp)
    lw      t0, 12(sp)
    lw      t1, 16(sp)
    lw      t2, 20(sp)
    lw      t3, 24(sp)
    lw      t4, 28(sp)
    addi    sp, sp, 32
    uret

# draw_cell same as provided, reused without change
# --------------------------------------------------------
# Dummy draw_cell: Draw red to address for demonstration (to be updated if needed)
# a0 = key scan code
# --------------------------------------------------------
draw_cell:
    addi    sp, sp, -4
    sw      ra, 0(sp)

    li      t0, RED
    li      t1, MONITOR_SCREEN
    sw      t0, 0(t1)

    lw      ra, 0(sp)
    addi    sp, sp, 4
    jr      ra