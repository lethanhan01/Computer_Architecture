.eqv SEVENSEG_LEFT    0xFFFF0011    # Dia chi cua den led 7 doan trai 
                                    #     Bit 0 = doan a 
                                    #     Bit 1 = doan b 
                                    #     ...    
                                    #     Bit 7 = dau . 
.eqv SEVENSEG_RIGHT   0xFFFF0010    # Dia chi cua den led 7 doan phai 
.data
char: .word 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F 
.text 
main: 
    la	    s0,  char
    lw      s1, 4(s0)
    lw	    s2, 12(s0) 	
print:    
    add      a0,  zero, s2               # set value for segments 
    jal     SHOW_7SEG_LEFT               # show 
    add      a0,  zero, s1               # set value for segments 
    jal     SHOW_7SEG_RIGHT              # show    
exit:      
    li      a7, 10 
    ecall 
end_main: 
 
# --------------------------------------------------------------- 
# Function  SHOW_7SEG_LEFT : turn on/off the 7seg 
# param[in]  a0   value to shown        
# remark     t0 changed 
# --------------------------------------------------------------- 
SHOW_7SEG_LEFT:   
    li      t0, SEVENSEG_LEFT   # assign port's address  
    sb      a0, 0(t0)           # assign new value   
    jr      ra 
                  
# --------------------------------------------------------------- 
# Function  SHOW_7SEG_RIGHT : turn on/off the 7seg 
# param[in]  a0   value to shown        
# remark     t0 changed 
# --------------------------------------------------------------- 
SHOW_7SEG_RIGHT:  
    li   t0, SEVENSEG_RIGHT     # assign port's address 
    sb   a0, 0(t0)              # assign new value  
    jr   ra 