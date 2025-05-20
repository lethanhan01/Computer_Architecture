.data
buffer: .space 21   # Bộ nhớ để lưu chuỗi ký tự, tối đa 20 ký tự + 1 ký tự kết thúc
newline: .asciz "\n" # Ký tự xuống dòng

.text
.global _start

_start:
    la a0, buffer  # Load địa chỉ của buffer
    li t0, 0       # Bộ đếm số ký tự nhập vào

read_loop:
    li a7, 12      # syscall read char
    ecall          # Đọc một ký tự từ bàn phím

    add t1, a0, t0  # Tính địa chỉ buffer + t0
    lb t2, 0(t1)   # Load ký tự vừa nhập vào t2
    li t3, 10      # Mã ASCII của Enter
    beq t2, t3, end_input # Nếu nhập Enter, dừng

    sb t2, 0(t1)   # Lưu ký tự vào buffer
    addi t0, t0, 1 # Tăng bộ đếm ký tự
    li t3, 20
    blt t0, t3, read_loop # Nếu chưa đủ 20 ký tự, tiếp tục nhập

end_input:
    add t1, a0, t0  # Tính địa chỉ kết thúc chuỗi
    li t2, 0       # Ký tự kết thúc chuỗi
    sb t2, 0(t1)   # Gán null terminator

    # In chuỗi theo chiều ngược lại
    print_reverse:
        addi t0, t0, -1
        blt t0, zero, end_program # Nếu t0 < 0, kết thúc

        add t1, a0, t0  # Tính địa chỉ buffer + t0
        lb a0, 0(t1)  # Load ký tự
        li a7, 11  # syscall print char
        ecall

        j print_reverse # Lặp lại để in ký tự tiếp theo

end_program:
    li a7, 10  # syscall exit
    ecall
