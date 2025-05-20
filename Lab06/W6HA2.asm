.data 
A: .word 3 5 -1 9 2        # Mảng A chứa các giá trị 3, 5, -1, 9, 2
Aend: .word                # Địa chỉ kết thúc của mảng A
space: .asciz " "          # Chuỗi khoảng trắng
newline: .asciz "\n"       # Chuỗi xuống dòng

.text 
main: 
	la a0, A               # a0 = địa chỉ của phần tử đầu tiên trong mảng A (A[0])
	la a1, Aend            # a1 = địa chỉ kết thúc của mảng A
	addi a1, a1, -4        # a1 = địa chỉ của phần tử cuối cùng trong mảng A (A[n-1])
	j sort                 # Nhảy đến thủ tục sắp xếp (sort)

after_sort: 
	li a7, 10              # Chuẩn bị kết thúc chương trình
	ecall                  # Gọi hệ thống để kết thúc chương trình

end_main: 

# -------------------------------------------------------------- 
# Thủ tục sort (sắp xếp chọn tăng dần sử dụng con trỏ) 
# Cách sử dụng thanh ghi trong chương trình sắp xếp: 
# a0: con trỏ đến phần tử đầu tiên trong phần chưa sắp xếp 
# a1: con trỏ đến phần tử cuối cùng trong phần chưa sắp xếp 
# t0: biến tạm để lưu giá trị của phần tử cuối cùng 
# s0: con trỏ đến phần tử lớn nhất trong phần chưa sắp xếp 
# s1: giá trị của phần tử lớn nhất trong phần chưa sắp xếp 
# -------------------------------------------------------------- 
sort: 
	la a0, A               # a0 = địa chỉ của phần tử đầu tiên trong mảng A
	beq a0, a1, done       # Nếu danh sách chỉ có một phần tử, nó đã được sắp xếp
	j max                  # Gọi thủ tục tìm phần tử lớn nhất (max)

after_max: 
	lw t0, 0(a1)           # Load giá trị của phần tử cuối cùng vào t0
	sw t0, 0(s0)           # Gán giá trị của phần tử cuối cùng vào vị trí của phần tử lớn nhất
	sw s1, 0(a1)           # Gán giá trị lớn nhất vào vị trí của phần tử cuối cùng
	addi a1, a1, -4        # Giảm con trỏ đến phần tử cuối cùng
	j print_array          # In mảng sau mỗi lần sắp xếp

done: 

# --------------------------------------------------------------------- 
# Thủ tục max 
# Chức năng: tìm giá trị và địa chỉ của phần tử lớn nhất trong danh sách 
# a0: con trỏ đến phần tử đầu tiên 
# a1: con trỏ đến phần tử cuối cùng 
# --------------------------------------------------------------------- 
max: 
	addi s0, a0, 0         # Khởi tạo con trỏ max trỏ đến phần tử đầu tiên
	lw s1, 0(s0)           # Khởi tạo giá trị max bằng giá trị của phần tử đầu tiên
	addi t0, a0, 0         # Khởi tạo con trỏ next trỏ đến phần tử đầu tiên

loop: 
	beq t0, a1, ret        # Nếu next = last, trở về
	addi t0, t0, 4         # Di chuyển đến phần tử tiếp theo
	lw t1, 0(t0)           # Load giá trị của phần tử tiếp theo vào t1
	blt t1, s1, loop       # Nếu (next) < (max), lặp lại
	addi s0, t0, 0         # Phần tử tiếp theo là phần tử lớn nhất mới
	addi s1, t1, 0         # Giá trị tiếp theo là giá trị lớn nhất mới
	j loop                 # Thay đổi hoàn tất; lặp lại

ret: 
	j after_max            # Trở về sau khi tìm được phần tử lớn nhất

print_array: 
	la t0, A               # t0 = địa chỉ của phần tử đầu tiên trong mảng A (A[0])
	la t1, Aend            # t1 = địa chỉ kết thúc của mảng A
	addi t1, t1, -4        # t1 = địa chỉ của phần tử cuối cùng trong mảng A (A[n-1])

print_loop: 
	lw a0, 0(t0)           # Load giá trị của phần tử hiện tại vào a0
	li a7, 1               # Chuẩn bị để in số nguyên
	ecall                  # Gọi hệ thống để in số nguyên
	li a7, 4               # Chuẩn bị để in chuỗi
	la a0, space            # In khoảng trắng
	ecall                  # Gọi hệ thống để in chuỗi
	bge t0, t1, print_done # Nếu t0 >= t1, kết thúc in
	addi t0, t0, 4         # Di chuyển đến phần tử tiếp theo
	j print_loop           # Lặp lại vòng lặp in

print_done: 
	li a7, 4               # Chuẩn bị để in chuỗi
	la a0, newline          # In xuống dòng
	ecall                  # Gọi hệ thống để in chuỗi
	j sort                 # Lặp lại quá trình sắp xếp cho danh sách nhỏ hơn