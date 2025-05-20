.data
msg_max:    .asciz        # Chuỗi để in giá trị lớn nhất (chưa khởi tạo)
msg_min:    .asciz        # Chuỗi để in giá trị nhỏ nhất (chưa khởi tạo)
comma:      .asciz        # Chuỗi dấu phẩy (chưa khởi tạo)
newline:    .asciz        # Chuỗi xuống dòng (chưa khởi tạo)

.text
variable:                 # Nhãn khởi tạo các biến
    addi a0, zero, 2      # a0 = 2
    addi a1, zero, 6      # a1 = 6
    addi a2, zero, 1      # a2 = 1
    addi a3, zero, -3     # a3 = -3
    addi a4, zero, 5      # a4 = 5
    addi a5, zero, 3      # a5 = 3
    addi a6, zero, 2      # a6 = 2
    addi a7, zero, 9      # a7 = 9

main:
    addi sp, sp, -32      # Dịch con trỏ stack xuống 32 byte (8 words)
    sw a0, 0(sp)          # Lưu a0 vào stack[0]
    sw a1, 4(sp)          # Lưu a1 vào stack[4]
    sw a2, 8(sp)          # Lưu a2 vào stack[8]
    sw a3, 12(sp)         # Lưu a3 vào stack[12]
    sw a4, 16(sp)         # Lưu a4 vào stack[16]
    sw a5, 20(sp)         # Lưu a5 vào stack[20]
    sw a6, 24(sp)         # Lưu a6 vào stack[24]
    sw a7, 28(sp)         # Lưu a7 vào stack[28]
    li t6, 8              # t6 = 8 (số lượng phần tử)

    addi a0, sp, 0        # Truyền địa chỉ mảng vào a0
    jal find_max_min      # Gọi hàm tìm max/min

    li a7, 10             # Chuẩn bị syscall exit
    ecall                 # Kết thúc chương trình

find_max_min:
    lw s0, 0(a0)          # Khởi tạo max = phần tử đầu (s0)
    lw s2, 0(a0)          # Khởi tạo min = phần tử đầu (s2)
    li s1, 0              # Chỉ số của max (s1)
    li s3, 0              # Chỉ số của min (s3)

    li t0, 1              # Bộ đếm vòng lặp i = 1 (t0)
loop:
    bge t0, t6, done      # Nếu i >= số phần tử -> kết thúc
    add t1, t0, t0        # t1 = i*2
    add t1, t1, t1        # t1 = i*4 (offset phần tử thứ i)
    add t2, a0, t1        # t2 = địa chỉ phần tử thứ i
    lw t3, 0(t2)          # t3 = giá trị phần tử thứ i
    
    bge t3, s0, update_max # Nếu t3 >= max -> cập nhật max
    ble t3, s2, update_min # Nếu t3 <= min -> cập nhật min
    j next                # Nhảy qua next

update_max:
    mv s0, t3             # Cập nhật giá trị max mới
    mv s1, t0             # Cập nhật chỉ số max mới
    j next                # Tiếp tục vòng lặp

update_min:
    mv s2, t3             # Cập nhật giá trị min mới
    mv s3, t0             # Cập nhật chỉ số min mới

next:
    addi t0, t0, 1        # Tăng bộ đếm i++
    j loop                # Lặp lại

done:
    jr ra                 # Trở về hàm gọi