.eqv IN_ADDRESS_HEXA_KEYBOARD   0xFFFF0012  # Address of keyboard
.eqv OUT_ADDRESS_HEXA_KEYBOARD  0xFFFF0014  # Output address of keyboard
.eqv MONITOR_SCREEN             0x10010000  # Start address of display memory

# Bitmap display settings: Unit 32x32, Display 128x128 pixels
# This creates a 4x4 grid where each cell is 32x32 pixels

# Color constants
.eqv BLACK                      0x00000000
.eqv WHITE                      0x00FFFFFF
.eqv RED                        0x00FF0000
.eqv GREEN                      0x0000FF00
.eqv BLUE                       0x000000FF
.eqv YELLOW                     0x00FFFF00
.eqv MAGENTA                    0x00FF00FF
.eqv CYAN                       0x0000FFFF
.eqv ORANGE                     0x00FF8000
.eqv PURPLE                     0x008000FF
.eqv CARD_BACK                  0x00808080  # Gray for face-down cards

# Game constants
.eqv GRID_SIZE                  4
.eqv TOTAL_CARDS               16
.eqv PAIRS_COUNT               8
.eqv CARD_FACE_DOWN            0
.eqv CARD_FACE_UP              1
.eqv CARD_MATCHED              2
.eqv CELL_SIZE                 32           # Each cell is 32x32 pixels
.eqv DISPLAY_WIDTH             4            # 4 cells wide (128/32)

.data 
message:        .asciz "Memory Card Game Started!\n"
win_message:    .asciz "Congratulations! You won!\n"
card_colors:    .word RED, GREEN, BLUE, YELLOW, MAGENTA, CYAN, ORANGE, PURPLE
                .word RED, GREEN, BLUE, YELLOW, MAGENTA, CYAN, ORANGE, PURPLE

# Game state arrays (16 cards)
card_states:    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
card_positions: .byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15

# Game variables
first_card:     .word -1        # Index of first flipped card (-1 means none)
second_card:    .word -1        # Index of second flipped card
flip_count:     .word 0         # Number of cards currently flipped
matched_pairs:  .word 0         # Number of matched pairs
game_over:      .word 0         # Game over flag

# Random seed
rand_seed:      .word 12345

# --------------------------------------------------------
# MAIN Procedure 
# --------------------------------------------------------
.text 
li  s10, MONITOR_SCREEN 
main: 
    # Initialize game
    jal     init_game
    
    # Load the interrupt service routine address to the UTVEC register 
    la      t0, handler 
    csrw    utvec, t0 
    
    # Set the UEIE (User External Interrupt Enable) bit in UIE register 
    li      t1, 0x100 
    csrs    uie, t1       # uie - ueie bit (bit 8) 
    
    # Set the UIE (User Interrupt Enable) bit in USTATUS register 
    csrsi   ustatus, 1    # ustatus - enable uie (bit 0) 
 
    # Enable the interrupt of keypad of Digital Lab Sim 
    li      t1, IN_ADDRESS_HEXA_KEYBOARD 
    li      t3, 0x80            # bit 7 = 1 to enable interrupt    
    sb      t3, 0(t1)
    
    # Print start message
    li      a7, 4      
    la      a0, message 
    ecall
 
    # --------------------------------------------------------
    # No-end loop, main program
    # --------------------------------------------------------
loop:    
    # Check if game is over
    la      t0, game_over
    lw      t1, 0(t0)
    bnez    t1, end_game
    
    nop 
    nop 
    nop 
    j       loop 

end_game:
    # Print win message
    li      a7, 4      
    la      a0, win_message 
    ecall
    j       loop

end_main:

# --------------------------------------------------------
# Initialize game - shuffle cards and set initial display
# --------------------------------------------------------
init_game:
    addi    sp, sp, -16
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    
    # Shuffle cards using simple random algorithm
    jal     shuffle_cards
    
    # Initialize all cards as face down
    la      t0, card_states
    li      t1, 0
init_loop:
    li      t2, CARD_FACE_DOWN
    add     t3, t0, t1
    sb      t2, 0(t3)
    addi    t1, t1, 1
    li      t2, TOTAL_CARDS
    blt     t1, t2, init_loop
    
    # Reset game variables
    la      t0, first_card
    li      t1, -1
    sw      t1, 0(t0)
    
    la      t0, second_card
    sw      t1, 0(t0)
    
    la      t0, flip_count
    sw      zero, 0(t0)
    
    la      t0, matched_pairs
    sw      zero, 0(t0)
    
    la      t0, game_over
    sw      zero, 0(t0)
    
    # Clear screen first
    jal     clear_screen
    
    # Draw initial board (all cards face down)
    jal     draw_board
    
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    addi    sp, sp, 16
    jr      ra

# --------------------------------------------------------
# Clear the entire screen
# --------------------------------------------------------
clear_screen:
    addi    sp, sp, -12
    sw      s0, 0(sp)
    sw      s1, 4(sp)
    sw      s2, 8(sp)
    
    li      s0, MONITOR_SCREEN
    li      s1, 0                   # Counter
    li      s2, 1024                # Total words to clear (128*128/4/4 = 1024)
    
clear_loop:
    sw      zero, 0(s0)
    addi    s0, s0, 4
    addi    s1, s1, 1
    blt     s1, s2, clear_loop
    
    lw      s0, 0(sp)
    lw      s1, 4(sp)
    lw      s2, 8(sp)
    addi    sp, sp, 12
    jr      ra

# --------------------------------------------------------
# Simple shuffle algorithm using Linear Congruential Generator
# --------------------------------------------------------
shuffle_cards:
    addi    sp, sp, -20
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    sw      s3, 16(sp)
    
    li      s0, 15              # Start from last element
shuffle_loop:
    # Generate random number
    jal     get_random
    mv      s1, a0              # Random number in s1
    
    # Get random index (0 to s0)
    addi    t0, s0, 1
    remu    s1, s1, t0          # s1 = random index
    
    # Swap card_positions[s0] with card_positions[s1]
    la      t0, card_positions
    add     t1, t0, s0          # Address of card_positions[s0]
    add     t2, t0, s1          # Address of card_positions[s1]
    
    lb      t3, 0(t1)           # Load card_positions[s0]
    lb      t4, 0(t2)           # Load card_positions[s1]
    
    sb      t4, 0(t1)           # Store to card_positions[s0]
    sb      t3, 0(t2)           # Store to card_positions[s1]
    
    addi    s0, s0, -1
    bgez    s0, shuffle_loop
    
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    lw      s3, 16(sp)
    addi    sp, sp, 20
    jr      ra

# --------------------------------------------------------
# Generate random number using LCG
# Returns random number in a0
# --------------------------------------------------------
get_random:
    la      t0, rand_seed
    lw      t1, 0(t0)           # Load current seed
    
    li      t2, 1103515245      # LCG multiplier
    li      t3, 12345           # LCG increment
    
    mul     t1, t1, t2          # seed * multiplier
    add     t1, t1, t3          # + increment
    
    sw      t1, 0(t0)           # Store new seed
    
    # Return positive value
    srli    a0, t1, 1           # Shift right to get positive value
    jr      ra

# --------------------------------------------------------
# Draw the entire game board
# --------------------------------------------------------
draw_board:
    addi    sp, sp, -16
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    
    li      s0, 0               # Card index
draw_loop:
    mv      a0, s0
    jal     draw_card
    
    addi    s0, s0, 1
    li      t0, TOTAL_CARDS
    blt     s0, t0, draw_loop
    
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    addi    sp, sp, 16
    jr      ra

# --------------------------------------------------------
# Draw a single card (fills entire 32x32 cell)
# a0 - card index (0-15)
# --------------------------------------------------------
draw_card:
    addi    sp, sp, -28
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    sw      s3, 16(sp)
    sw      s4, 20(sp)
    sw      s5, 24(sp)
    
    mv      s0, a0              # Card index
    
    # Get card state
    la      t0, card_states
    add     t1, t0, s0
    lb      s1, 0(t1)           # Card state
    
    # Calculate grid position
    li      t0, 4
    div     s2, s0, t0          # Row = index / 4
    rem     s3, s0, t0          # Col = index % 4
    
    # Determine color based on state
    li      t0, CARD_FACE_DOWN
    beq     s1, t0, set_gray_color
    
    li      t0, CARD_MATCHED
    beq     s1, t0, set_card_color
    
    # CARD_FACE_UP
set_card_color:
    # Get card color based on shuffled position
    la      t0, card_positions
    add     t1, t0, s0
    lb      t1, 0(t1)           # Get original card index
    
    la      t0, card_colors
    slli    t2, t1, 2           # Convert to word offset
    add     t0, t0, t2
    lw      s4, 0(t0)           # Load color
    j       draw_cell_filled
    
set_gray_color:
    li      s4, CARD_BACK       # Gray color for face-down cards
    
draw_cell_filled:
    # Fill the entire 32x32 cell with the color
    # Calculate starting memory address
    li      t0, CELL_SIZE       # 32 pixels per cell
    mul     t1, s2, t0          # Row offset in pixels
    li      t2, DISPLAY_WIDTH   # 4 cells per row
    mul     t1, t1, t2          # Convert to memory offset
    slli    t1, t1, 2           # Convert to bytes (4 bytes per word)
    
    mul     t2, s3, t0          # Column offset in pixels  
    slli    t2, t2, 2           # Convert to bytes
    
    add     s5, s10, t1         # Base address + row offset
    add     s5, s5, t2          # + column offset
    
    # Fill 32x32 area (but we're working with units, so fill 1x1 unit)
    sw      s4, 0(s5)           # Draw the cell
    
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    lw      s3, 16(sp)
    lw      s4, 20(sp)
    lw      s5, 24(sp)
    addi    sp, sp, 28
    jr      ra

# --------------------------------------------------------
# Handle card flip
# a0 - card index to flip
# --------------------------------------------------------
flip_card:
    addi    sp, sp, -16
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    
    mv      s0, a0              # Card index
    
    # Check if card is already matched or face up
    la      t0, card_states
    add     t1, t0, s0
    lb      t2, 0(t1)
    
    li      t3, CARD_FACE_DOWN
    bne     t2, t3, flip_exit   # Don't flip if not face down
    
    # Check how many cards are currently flipped
    la      t0, flip_count
    lw      t1, 0(t0)
    
    li      t2, 2
    bge     t1, t2, flip_exit   # Don't flip if 2 cards already flipped
    
    # Flip the card
    la      t0, card_states
    add     t1, t0, s0
    li      t2, CARD_FACE_UP
    sb      t2, 0(t1)
    
    # Update flip count
    la      t0, flip_count
    lw      t1, 0(t0)
    addi    t1, t1, 1
    sw      t1, 0(t0)
    
    # Store card reference
    li      t2, 1
    beq     t1, t2, store_first_card
    
    # This is the second card
    la      t0, second_card
    sw      s0, 0(t0)
    
    # Draw the card
    mv      a0, s0
    jal     draw_card
    
    # Check for match after short delay
    jal     check_match
    j       flip_exit
    
store_first_card:
    la      t0, first_card
    sw      s0, 0(t0)
    
    # Draw the card
    mv      a0, s0
    jal     draw_card
    
flip_exit:
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    addi    sp, sp, 16
    jr      ra

# --------------------------------------------------------
# Check if two flipped cards match
# --------------------------------------------------------
check_match:
    addi    sp, sp, -16
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    
    # Get both card indices
    la      t0, first_card
    lw      s0, 0(t0)
    la      t0, second_card
    lw      s1, 0(t0)
    
    # Get card colors from shuffled positions
    la      t0, card_positions
    add     t1, t0, s0
    lb      t1, 0(t1)           # First card's original index
    
    add     t2, t0, s1
    lb      t2, 0(t2)           # Second card's original index
    
    # Compare colors (each color appears twice)
    srli    t3, t1, 1           # Color group of first card (divide by 2)
    srli    t4, t2, 1           # Color group of second card (divide by 2)
    
    beq     t3, t4, match_found
    
    # No match - flip cards back after delay
    li      a0, 1000000         # Delay
    jal     delay
    
    # Flip first card back
    la      t0, card_states
    add     t1, t0, s0
    li      t2, CARD_FACE_DOWN
    sb      t2, 0(t1)
    
    # Flip second card back
    add     t1, t0, s1
    sb      t2, 0(t1)
    
    # Redraw both cards
    mv      a0, s0
    jal     draw_card
    mv      a0, s1
    jal     draw_card
    
    j       match_end
    
match_found:
    # Mark both cards as matched
    la      t0, card_states
    add     t1, t0, s0
    li      t2, CARD_MATCHED
    sb      t2, 0(t1)
    
    add     t1, t0, s1
    sb      t2, 0(t1)
    
    # Increment matched pairs
    la      t0, matched_pairs
    lw      t1, 0(t0)
    addi    t1, t1, 1
    sw      t1, 0(t0)
    
    # Check if game is won
    li      t2, PAIRS_COUNT
    beq     t1, t2, game_won
    
    j       match_end
    
game_won:
    la      t0, game_over
    li      t1, 1
    sw      t1, 0(t0)
    
match_end:
    # Reset flip tracking
    la      t0, first_card
    li      t1, -1
    sw      t1, 0(t0)
    
    la      t0, second_card
    sw      t1, 0(t0)
    
    la      t0, flip_count
    sw      zero, 0(t0)
    
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    addi    sp, sp, 16
    jr      ra

# --------------------------------------------------------
# Simple delay function
# a0 - delay count
# --------------------------------------------------------
delay:
    li      t0, 0
delay_loop:
    addi    t0, t0, 1
    blt     t0, a0, delay_loop
    jr      ra

# --------------------------------------------------------
# Convert key scan code to card index
# a0 - key scan code
# Returns card index in a0, or -1 if invalid
# --------------------------------------------------------
key_to_card:
    # Map key scan code to grid position:
    # Row 1: 0x11(0), 0x21(1), 0x41(2), 0x81(3)
    # Row 2: 0x12(4), 0x22(5), 0x42(6), 0x82(7)
    # Row 3: 0x14(8), 0x24(9), 0x44(10), 0x84(11)
    # Row 4: 0x18(12), 0x28(13), 0x48(14), 0x88(15)
    
    # Row 1
    li      t0, 0x11
    beq     a0, t0, return_0
    li      t0, 0x21
    beq     a0, t0, return_1
    li      t0, 0x41
    beq     a0, t0, return_2
    li      t0, 0x81
    beq     a0, t0, return_3
    
    # Row 2
    li      t0, 0x12
    beq     a0, t0, return_4
    li      t0, 0x22
    beq     a0, t0, return_5
    li      t0, 0x42
    beq     a0, t0, return_6
    li      t0, 0x82
    beq     a0, t0, return_7
    
    # Row 3
    li      t0, 0x14
    beq     a0, t0, return_8
    li      t0, 0x24
    beq     a0, t0, return_9
    li      t0, 0x44
    beq     a0, t0, return_10
    li      t0, 0x84
    beq     a0, t0, return_11
    
    # Row 4
    li      t0, 0x18
    beq     a0, t0, return_12
    li      t0, 0x28
    beq     a0, t0, return_13
    li      t0, 0x48
    beq     a0, t0, return_14
    li      t0, 0x88
    beq     a0, t0, return_15
    
    # Invalid key
    li      a0, -1
    jr      ra
    
return_0:  
li a0, 0  
jr ra
return_1:  
li a0, 1  
jr ra
return_2:  li a0, 2  
jr ra
return_3:  li a0, 3  
jr ra
return_4:  li a0, 4  
jr ra
return_5:  li a0, 5  
jr ra
return_6:  li a0, 6  
jr ra
return_7:  li a0, 7  
jr ra
return_8:  li a0, 8  
jr ra
return_9:  li a0, 9  
jr ra
return_10: li a0, 10 
jr ra
return_11: li a0, 11 
jr ra
return_12: li a0, 12 
jr ra
return_13: li a0, 13 
jr ra
return_14: li a0, 14 
jr ra
return_15: li a0, 15 
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
    # Convert key scan code to card index
    mv      a0, t1
    jal     key_to_card
    
    # Check if valid card index
    li      t0, -1
    beq     a0, t0, handler_exit
    
    # Flip the card
    jal     flip_card
     
handler_exit:
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