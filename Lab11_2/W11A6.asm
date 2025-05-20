.data 
overflow_msg: 
.asciz "Error: Integer overflow occurred!\n" 
.text 
.globl main 
main: 
	# --- Khởi tạo ngăn xếp cho main và lưu ra --- 
	addi   	sp, sp, -16  
	sw      	ra,  12(sp) 
	# --- Thiết lập ISR và bật ngắt mềm --- 
	la     	t0, overflow_isr  
	csrrw   zero, utvec,  t0     # utvec <- &overflow_isr 
	csrrsi  zero, ustatus, 1     # UIE = 1 
	csrrsi  zero, uie,     1     # USIE = 1 
	# --- Khởi tạo số và cộng --- 
	li    s1, 0x7FFFFFFF        
	li    s2, 1  
	add   s3, s1, s2 
	# INT_MAX 
	# --- Kiểm tra overflow --- 
	xor     t0, s1, s2 
	srli    t0, t0, 31
	bne     t0, zero, no_overflow 
	xor     t0, s1, s3 
	srli    t0, t0, 31 
	beq     t0, zero, no_overflow  
# --- Overflow → kích soft-irq --- 
	csrrsi  zero, uip,   1 
	nop 
wait_irq: 
    j       wait_irq 
 
no_overflow: 
    # In kết quả bình thường 
    mv      a0, s3 
    li      a7, 1 
    ecall 
    li      a7, 11 
    li      a0, '\n' 
    ecall 
 
    # Restore và exit 
    lw      ra,  12(sp) 
    addi    sp, sp, 16 
    li      a7, 10 
    ecall 
# ========================== 
#   ISR: overflow_isr 
# ========================== 
overflow_isr: 
	# --- Sao lưu ngữ cảnh (alignment 16) --- 
	addi   sp, sp, -16  
	sw     ra,  12(sp) 
	sw     t0,   8(sp)  
	sw     t1,   4(sp)   
	# --- Lấy ucause vào t0 --- 
	csrrc   t0, ucause, zero     
	 # t0 = ucause 
	# --- Kiểm tra interrupt vs exception --- 
	li     t1, 0x80000000 
	and    t1, t0, t1 
	beq    t1, zero, end_isr     # nếu không phải interrupt, bỏ qua 
	# --- Lấy mã cause (lower 4 bits) --- 
	li     t1, 0xF 
	and    t0, t0, t1 
	bne    t0, zero, end_isr     # nếu không phải soft-irq (code=0), bỏ qua 
	# --- Clear USIP để tránh lặp lại IRQ --- 
	csrrci  zero, uip, 1 
	# --- In thông báo lỗi --- 
	la     a0, overflow_msg 
	li     a7, 4 
	ecall 
	# --- Exit --- 
	li     a7, 10 
	ecall 
end_isr: 
	# --- Khôi phục ngữ cảnh --- 
	lw      t1,  4(sp)  
	lw      t0,  8(sp) 
	lw      ra,  12(sp)
	addi    sp, sp, 16 
	uret 



