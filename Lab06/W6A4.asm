.data 
A:       
.word 50, 12, -3, 0, 7, 98, -12, 45, 3, 27   # Bộ dữ liệu mảng mới (10 phần tử) 
prompt:  .asciz " "       
space:   .asciz " "            
newline: .asciz "\n"           
.text 
.globl main 
main: 
	# Khởi tạo:  
	# Chuỗi in đầu dòng cho mảng 
	# Khoảng trắng giữa các phần tử 
	# Xuống dòng 
	# s0 = địa chỉ đầu mảng, s1 = số phần tử (10) 
	la    s0, A                 
	li    s1, 10                
	# s3 = chỉ số outer loop, bắt đầu từ 1 (vì phần tử A[0] được coi là đã sắp xếp) 
	li    s3, 1                 
outer_loop: 
	bge   s3, s1, sort_done    # Nếu i >= n thì mảng đã được sắp xếp 
	# Lấy key = A[i] 
	slli  t1, s3, 2            # t1 = i * 4 (để tính địa chỉ của A[i]) 
	add   t2, s0, t1           # t2 = địa chỉ của A[i] 
	lw    t3, 0(t2)            # t3 = key (giá trị cần chèn) 
	addi  s4, s3, -1           # s4 = j = i - 1 
  
inner_loop: 
    blt   s4, zero, inner_done   # Nếu j < 0, thoát vòng lặp bên trong 
    slli  t1, s4, 2               # t1 = j * 4 
    add   t2, s0, t1              # t2 = địa chỉ của A[j] 
    lw    s2, 0(t2)              # s2 = A[j] 
    ble   s2, t3, inner_done      # Nếu A[j] <= key, kết thúc vòng lặp bên trong 
    # Dời A[j] sang phải: A[j+1] = A[j] 
    addi  t1, s4, 1              # t1 = j + 1 
    slli  t1, t1, 2              # t1 = (j+1) * 4 
    add   t2, s0, t1             # t2 = địa chỉ của A[j+1] 
    sw    s2, 0(t2)              # di chuyển giá trị A[j] sang phải 
    addi  s4, s4, -1             # j = j - 1 
    j     inner_loop 
  
inner_done: 
    	addi  s4, s4, 1             # Vị trí chèn: j+1 
	slli  t1, s4, 2             # t1 = (j+1) * 4 
	add   t2, s0, t1            # t2 = địa chỉ của A[j+1] 
	sw    t3, 0(t2)             # Chèn key vào A[j+1] 	  
	# In mảng sau mỗi lượt chèn 
	jal   ra, printArray 
	addi  s3, s3, 1             
	j     outer_loop 
sort_done: 
	# i = i + 1 
	# In mảng cuối cùng đã được sắp xếp 
	jal   ra, printArray 
	li    a7, 10              
	ecall 
	# Kết thúc chương trình 
	#--------------------------------------------------------- 
	# Procedure printArray: 
	# In ra mảng theo định dạng "Array: <A[0]> <A[1]> ... <A[9]>\n" 
	#--------------------------------------------------------- 
printArray: 
	la    a0, prompt          
	li    a7, 4 
	ecall 
	la    t0, A               
	li    t1, 10              
print_loop: 
	# In chuỗi "Array: " 
	# t0 = địa chỉ đầu mảng A 
	# t1 = số phần tử cần in (10) 
	beq   t1, zero, print_done  # Nếu đã in hết các phần tử 
	lw    t2, 0(t0)           
	mv    a0, t2 
	li    a7, 1               
	ecall 
	# Tải phần tử hiện tại vào t2 
	# In số nguyên (ECALL với a7 = 1) 
	la    a0, space          # In khoảng trắng giữa các phần tử 
	li    a7, 4 
	ecall 
	addi  t0, t0, 4           
	addi  t1, t1, -1 
	j     print_loop 
print_done: 
	# Chuyển đến phần tử kế tiếp 
	la    a0, newline        # Xuống dòng sau khi in xong 
	li    a7, 4 
	ecall 
	jr    ra 
