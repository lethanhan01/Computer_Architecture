.eqv KEY_CODE       0xFFFF0004   # ASCII code from keyboard, 1 byte
.eqv KEY_READY      0xFFFF0000   # =1 if has a new keycode (Auto clear after lw)
.eqv DISPLAY_CODE   0xFFFF000C   # ASCII code to show, 1 byte
.eqv DISPLAY_READY  0xFFFF0008   # =1 if display is ready (Auto clear after sw)

.text
main:
    # Initialize port addresses
    li    a0, KEY_CODE
    li    a1, KEY_READY
    li    s0, DISPLAY_CODE
    li    s1, DISPLAY_READY

main_loop:
    # Wait for key press
    lw    t1, 0(a1)            # Check KEY_READY
    beqz  t1, main_loop        # Keep waiting if no key
    
    # Read key code
    lw    t0, 0(a0)            # t0 = ASCII character
    
    # Check lowercase letters (a-z)
    li    t3, 'a'
    blt   t0, t3, check_upper
    li    t3, 'z'
    bgt   t0, t3, check_upper
    addi  t0, t0, -32          # Convert to uppercase
    j     wait_display

check_upper:
    # Check uppercase letters (A-Z)
    li    t3, 'A'
    blt   t0, t3, check_digit
    li    t3, 'Z'
    bgt   t0, t3, check_digit
    addi  t0, t0, 32           # Convert to lowercase
    j     wait_display

check_digit:
    # Check digits (0-9)
    li    t3, '0'
    blt   t0, t3, other_char
    li    t3, '9'
    bgt   t0, t3, other_char
    j     wait_display          # Leave digits unchanged

other_char:
    li    t0, '*'              # Replace other chars with *

wait_display:
    # Wait until display is ready
    lw    t3, 0(s1)
    beqz  t3, wait_display
    
    # Display the character
    sw    t0, 0(s0)
    j     main_loop