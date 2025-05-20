.data
error:     	.asciz "Lỗi: kích thước mảng không hợp lệ\n"  
result:    	.asciz "Số chẵn lớn nhất nhỏ hơn mọi số lẻ là: "  
not_found_msg: 	.asciz "Không tìm được số chẵn thỏa mãn yêu cầu\n"  
no_odd_msg:    	.asciz "Không có số lẻ nào trong mảng. Số chẵn lớn nhất là: "

.align 2 			# Căn chỉnh dữ liệu theo địa chỉ chia hết cho 4 (tối ưu truy cập bộ nhớ)
array:  		.space 400  	# Cấp phát 400 byte (tối đa 100 phần tử int, mỗi phần tử 4 byte)

.text
main: 
    # Nhập kích thước mảng
    li a7, 5                  
    ecall
    mv s0, a0                  # Lưu kích thước mảng vào s0

    # Kiểm tra kích thước hợp lệ (0 < size <= 100)
    li t0, 0                   # t0 = 0
    ble s0, t0, Loi_kich_thuoc # Nếu size <= 0, báo lỗi
    li t0, 100                 # t0 = 100
    ble t0, s0, Loi_kich_thuoc # Nếu size > 100, báo lỗi

    # Nhập các phần tử mảng
    la s1, array               # s1 = địa chỉ gốc của mảng
    li s2, 0                   # s2 = biến đếm i = 0

read_loop:
    beq s2, s0, sort_array     # Nếu i == size, chuyển sang sắp xếp
    li a7, 1                   # In chỉ số phần tử hiện tại (i)
    mv a0, s2
    ecall
    
    li a7, 5                   # Đọc phần tử thứ i từ bàn phím
    ecall

# Lưu phần tử vào mảng: array[i] = a0
    slli t1, s2, 2             # t1 = i * 4 (offset phần tử thứ i)
    add t2, s1, t1             # t2 = địa chỉ array[i]
    sw a0, 0(t2)               # Lưu giá trị vào array[i]

    addi s2, s2, 1             # Tăng biến đếm i
    j read_loop                # Lặp lại vòng lặp

# Sắp xếp mảng tăng dần bằng Bubble Sort
sort_array:
    li t0, 0                   # t0 = i = 0 (vòng lặp ngoài)

outer_loop:
    bge t0, s0, find_result    # Nếu i >= size, chuyển sang tìm kết quả
    li t1, 0                   # t1 = j = 0 (vòng lặp trong)

inner_loop:
    sub t2, s0, t0             # t2 = size - i
    addi t2, t2, -1            # t2 = size - i - 1 (giới hạn vòng lặp trong)
    bge t1, t2, next_outer     # Nếu j >= size - i - 1, chuyển vòng ngoài

    # Load array[j] và array[j+1]
    slli t3, t1, 2             # t3 = j * 4
    add t4, s1, t3             # t4 = &array[j]
    lw t5, 0(t4)               # t5 = array[j]
    
    addi t6, t1, 1             # t6 = j + 1
    slli a1, t6, 2             # a1 = (j + 1) * 4
    add a2, s1, a1             # a2 = &array[j+1]
    lw a3, 0(a2)               # a3 = array[j+1]

    ble t5, a3, skip           # Nếu array[j] <= array[j+1], bỏ qua hoán đổi

    # Hoán đổi array[j] và array[j+1]
    sw a3, 0(t4)               # array[j] = array[j+1]
    sw t5, 0(a2)               # array[j+1] = array[j]

skip:
    addi t1, t1, 1             # j++
    j inner_loop
next_outer:
    addi t0, t0, 1             # i++
    j outer_loop

# Tìm số chẵn lớn nhất nhỏ hơn mọi số lẻ
find_result:
    li t0, 0                   # t0 = chỉ số duyệt mảng
    li t1, -1                  # t1 = vị trí số lẻ đầu tiên (khởi tạo -1)
    li t3, 0                   # t3 = flag (0: chưa tìm thấy số lẻ)

find_loop:
    beq t0, s0, handle_no_odd  # Nếu duyệt hết mảng, kiểm tra trường hợp không có số lẻ
    slli t2, t0, 2             # t2 = offset phần tử thứ t0
    add t4, s1, t2             # t4 = &array[t0]
    lw t5, 0(t4)               # t5 = array[t0]
    andi t6, t5, 1             # Kiểm tra LSB (0: chẵn, 1: lẻ)
    beq t6, zero, next_find    # Nếu chẵn, bỏ qua
    mv t1, t0                  # Lưu vị trí số lẻ đầu tiên
    li t3, 1                   # Đánh dấu đã tìm thấy số lẻ
    j check_position           # Kiểm tra vị trí số lẻ

next_find:
    addi t0, t0, 1             # Tăng chỉ số duyệt
    j find_loop

# Xử lý vị trí số lẻ đầu tiên
check_position:
    beq t1, zero, not_found    # Nếu số lẻ ở vị trí 0, không có số chẵn phía trước

    # Lấy phần tử ngay trước số lẻ đầu tiên (chắc chắn là số chẵn lớn nhất)
    addi t6, t1, -1            # t6 = t1 - 1
    slli t2, t6, 2             # Tính offset
    add t4, s1, t2             # t4 = &array[t6]
    lw a0, 0(t4)               # a0 = array[t6] (số chẵn cần tìm)

    # In kết quả
    li a7, 4
    la a0, result
    ecall
    
    lw a0, 0(t4)               # Load lại giá trị vào a0 để in ra kết quả
    li a7, 1
    ecall
    
    j exit                     # Kết thúc chương trình

# Trường hợp không có số lẻ 
handle_no_odd:
    beq t3, zero, print_max         # Nếu không tìm thấy số lẻ, in số chẵn lớn nhất

# Không tìm thấy số chẵn thỏa điều kiện 
not_found:
    li a7, 4
    la a0, not_found_msg
    ecall
    j exit

# In số chẵn lớn nhất (khi không có số lẻ) 
print_max:
    li a7, 4
    la a0, no_odd_msg
    ecall
    
    addi t0, s0, -1            # t0 = size - 1 (phần tử cuối mảng)
    slli t1, t0, 2             # Tính offset
    add t2, s1, t1             # t2 = &array[size-1]
    lw a0, 0(t2)               # a0 = array[size-1] (số lớn nhất)
    li a7, 1
    ecall
    j exit

# Xử lý lỗi kích thước mảng 
Loi_kich_thuoc:
    li a7, 4
    la a0, error
    ecall

# Kết thúc chương trình 
exit:
    li a7, 10
    ecall
