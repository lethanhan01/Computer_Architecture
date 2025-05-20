# Bài tập 2: Chèn M vào mảng đã sắp xếp tăng dần
# Input: Kích thước mảng, các phần tử mảng (đã sắp xếp), số nguyên M
# Output: Mảng sau khi chèn M và vẫn giữ thứ tự sắp xếp

.data
prompt_size: .asciz "Nhập kích thước mảng (tối đa 100): "
prompt_array: .asciz "Nhập các phần tử của mảng (đã sắp xếp tăng dần):\n"
prompt_element: .asciz "Phần tử thứ "
prompt_colon: .asciz ": "
prompt_m: .asciz "Nhập số nguyên M cần chèn: "
result_msg: .asciz "Mảng sau khi chèn M:\n"
space: .asciz " "
newline: .asciz "\n"
error_size: .asciz "Kích thước mảng không hợp lệ.\n"

array_storage: .space 404 # Cấp phát không gian cho tối đa 101 số nguyên (4 bytes/integer)
                           # Cần thêm 1 chỗ cho M

.text
.globl main

main:
    # --- Nhập kích thước mảng ---
    li a7, 4
    la a0, prompt_size
    ecall

    li a7, 5
    ecall
    mv s0, a0         # s0 = size (kích thước ban đầu)

    # Kiểm tra kích thước hợp lệ (0 < size <= 100)
    li t0, 0
    ble s0, t0, invalid_size # size <= 0
    li t0, 100
    bgt s0, t0, invalid_size # size > 100

    # --- Nhập các phần tử mảng ---
    li a7, 4
    la a0, prompt_array
    ecall

    la s1, array_storage # s1 = Địa chỉ bắt đầu của mảng
    li s2, 0             # s2 = i = 0 (biến đếm vòng lặp)

read_loop:
    # Kiểm tra điều kiện lặp (i < size)
    beq s2, s0, read_m # Nếu i == size, kết thúc đọc mảng

    # In thông báo "Phần tử thứ i: "
    li a7, 4
    la a0, prompt_element
    ecall
    li a7, 1
    mv a0, s2
    ecall
    li a7, 4
    la a0, prompt_colon
    ecall

    # Đọc phần tử thứ i
    li a7, 5
    ecall
    # Lưu phần tử vào mảng: array[i] = a0
    # Địa chỉ array[i] = base_address + i * 4
    slli t1, s2, 2    # t1 = i * 4
    add t2, s1, t1    # t2 = base_address + i * 4
    sw a0, 0(t2)      # Lưu giá trị đọc được vào địa chỉ t2

    # Tăng biến đếm i
    addi s2, s2, 1
    j read_loop

read_m:
    # --- Nhập số M cần chèn ---
    li a7, 4
    la a0, prompt_m
    ecall

    li a7, 5
    ecall
    mv s3, a0         # s3 = M

    # --- Tìm vị trí chèn (insertion_point) ---
    # Tìm chỉ số i nhỏ nhất sao cho array[i] >= M
    li s4, 0          # s4 = insertion_point = 0

find_insertion_point_loop:
    # Kiểm tra nếu đã duyệt hết mảng ban đầu (insertion_point == size)
    beq s4, s0, shift_elements # Nếu đúng, M sẽ được chèn vào cuối

    # Lấy giá trị array[insertion_point]
    slli t1, s4, 2
    add t2, s1, t1    # t2 = address of array[insertion_point]
    lw t3, 0(t2)      # t3 = array[insertion_point]

    # So sánh M với array[insertion_point]
    blt s3, t3, shift_elements # Nếu M < array[insertion_point], tìm thấy vị trí, nhảy đến shift_elements

    # Nếu M >= array[insertion_point], tiếp tục tìm
    addi s4, s4, 1
    j find_insertion_point_loop

shift_elements:
    # --- Dịch các phần tử từ cuối về vị trí chèn ---
    # Vòng lặp chạy từ i = size xuống insertion_point + 1
    # array[i] = array[i-1]
    mv t0, s0         # t0 = i = size (chỉ số của vị trí sau phần tử cuối cùng)

shift_loop:
    # Điều kiện dừng: i <= insertion_point
    ble t0, s4, insert_m # Nếu i <= insertion_point, dừng dịch chuyển

    # Tính địa chỉ array[i-1]
    addi t1, t0, -1   # t1 = i - 1
    slli t2, t1, 2    # t2 = (i - 1) * 4
    add t3, s1, t2    # t3 = address of array[i-1]
    lw t4, 0(t3)      # t4 = array[i-1]

    # Tính địa chỉ array[i]
    slli t5, t0, 2    # t5 = i * 4
    add t6, s1, t5    # t6 = address of array[i]
    sw t4, 0(t6)      # array[i] = array[i-1]

    # Giảm i
    addi t0, t0, -1
    j shift_loop

insert_m:
    # --- Chèn M vào vị trí insertion_point ---
    slli t1, s4, 2
    add t2, s1, t1    # t2 = address of array[insertion_point]
    sw s3, 0(t2)      # array[insertion_point] = M

    # --- Tăng kích thước mảng lên 1 ---
    addi s0, s0, 1    # new_size = old_size + 1

    # --- In mảng kết quả ---
    li a7, 4
    la a0, result_msg
    ecall

    li s2, 0          # i = 0

print_loop:
    # Kiểm tra điều kiện lặp (i < new_size)
    beq s2, s0, end_print # Nếu i == new_size, kết thúc in

    # Lấy giá trị array[i]
    slli t1, s2, 2
    add t2, s1, t1
    lw a0, 0(t2)      # Load array[i] vào a0 để in

    # In phần tử array[i]
    li a7, 1
    ecall

    # In dấu cách
    li a7, 4
    la a0, space
    ecall

    # Tăng i
    addi s2, s2, 1
    j print_loop

end_print:
    # In ký tự xuống dòng cuối cùng
    li a7, 4
    la a0, newline
    ecall
    j exit

invalid_size:
    li a7, 4
    la a0, error_size
    ecall
    # Kết thúc chương trình
    j exit

exit:
    li a7, 10         # System call code for exit
    ecall