 .data
msg_input: .asciz "Enter a string: " 
buffer: .space 21               
.text
_start:
    # In thông báo yêu cầu nhập chuỗi
    la a0, msg_input         
    li a7, 4                 
    ecall    
    # Khởi tạo các thanh ghi
    li t0, 0                 # t0 = 0 (biến đếm số kí tự nhập vào)
    la t1, buffer            # t1 = Địa chỉ bắt đầu của buffer (d�ng �? u chuỗi)
input_loop:
    # Đọc một kí tự từ bàn phím
    li a7, 12                # Syscall number for read_char
    ecall
    mv t2, a0                # Lưu kí tự vào t2

    # Kiểm tra xem kí tự nhập vào có phải là Enter (mã ASCII 10) hay không
    li t3, 10                # ASCII code của kí tự Enter
    beq t2, t3, end_input    # Nếu kí tự là Enter thì kết thúc nhập

    # Kiểm tra độ dài chuỗi có vượt quá 20 kí tự không
    li t3, 20
    beq t0, t3, end_input    # Nếu độ dài chuỗi đạt 20 thì kết thúc nhập

    # Lưu kí tự vào bộ nhớ và tăng biến đếm
    sb t2, 0(t1)             # Lưu kí tự vào buffer tại vị trí t1
    addi t1, t1, 1           # Di chuyển con trỏ t1 đến vị trí tiếp theo trong buffer
    addi t0, t0, 1           # Tăng biến đếm t0
    j input_loop             # Quay lại vòng lặp nhập tiếp kí tự
end_input:
    # In chuỗi ngược lại
    addi t1, t1, -1          # Quay con trỏ t1 về vị trí cuối của chuỗi đã nhập
reverse_print_loop:
    lb a0, 0(t1)             # Đọc kí tự từ vị trí hiện tại của buffer
    beq a0, zero, done       # Nếu gặp kí tự null thì kết thúc
    # In kí tự
    li a7, 11               
    ecall
    addi t1, t1, -1          # Di chuyển con trỏ ngược lại (lùi 1 byte)
    j reverse_print_loop     # Tiếp tục in kí tự ngược lại
done:
    # Dừng chương trình
    li a7, 10                # exit
    ecall


