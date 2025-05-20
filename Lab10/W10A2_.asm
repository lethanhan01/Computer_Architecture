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
    li	    a7, 8
    ecall
    add	    t1, t1, a0
    addi    t3, t3, 10 
    rem     s1, t1, t3
    div	    s2, t1, t3
    
    slli    s1, s1, 2
    add     s0, s0, s1
    lw      a4, 0(s0)
    add     a0,  zero, a4               # set value for segments 
    jal     SHOW_7SEG_RIGHT              # show
    
    slli    s2, s2, 2  
    add     s0, s0, s2
    lw      a5, 0(s0)
    add     a0,  zero, a5               # set value for segments 
    jal     SHOW_7SEG_LEFT  	
    
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