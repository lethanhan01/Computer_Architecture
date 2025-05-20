.data
buffer: .space 100               # Khai báo vùng nhớ 100 byte để lưu chuỗi nhập vào

.text 
main:
    # Đọc xâu ký tự từ người dùng
    li a7, 8                     
    la a0, buffer                # Địa chỉ buffer để lưu chuỗi nhập
    li a1, 100                   # Số ký tự tối đa có thể đọc (100-1 để phòng ký tự null)
    ecall                        # Gọi hệ thống

    # Bắt đầu quá trình đổi chữ hoa-thường
    la t0, buffer                # t0 = con trỏ trỏ tới đầu chuỗi

loop:
    lb t1, 0(t0)                 # Load byte hiện tại từ chuỗi vào t1
    beq t1, zero, done           # Nếu gặp ký tự null (kết thúc chuỗi) thì nhảy đến done

    # Kiểm tra xem ký tự có phải là chữ thường (a-z)
    li t2, 97                    # ASCII code của 'a'
    li t3, 122                     # ASCII code của 'z'
    blt t1, t2, check_number     	        # Nếu < 'a' thì kiểm tra chữ hoa
    blt t3, t1, check_upper              # Nếu > 'z' thì kiểm tra chữ hoa
	
    # Xử lý chữ thường -> hoa
    li t4, 32                    # Hiệu số giữa chữ hoa và thường trong ASCII
    sub t1, t1, t4               # Chuyển thành chữ hoa bằng cách trừ 32
    sb t1, 0(t0)                 # Lưu ký tự đã chuyển đổi trở lại bộ nhớ
    j next_char                  # Nhảy đến ký tự tiếp theo
check_number:
    li t2, 48
    li t3, 57
    blt t1, t2, check_upper
    blt t3, t1, check_upper
    
    li t4, 49
    add t1, t1, t4
    sb t1, 0(t0)
    j next_char
    
check_upper:
    # Kiểm tra xem ký tự có phải là chữ hoa (A-Z)
    li t2, 65                    # ASCII code của 'A'
    li t3, 90                    # ASCII code của 'Z'
    blt t1, t2, next_char        # Nếu < 'A' thì bỏ qua
    bgt t1, t3, next_char        # Nếu > 'Z' thì bỏ qua

    # Xử lý chữ hoa -> chữ thường
    li t4, 32                    # Hiệu số giữa chữ hoa và thường trong ASCII
    add t1, t1, t4               # Chuyển thành chữ thường bằng cách cộng 32
    sb t1, 0(t0)                 # Lưu ký tự đã chuyển đổi trở lại bộ nhớ

next_char:
    addi t0, t0, 1               # Di chuyển con trỏ đến ký tự tiếp theo trong chuỗi
    j loop                       # Lặp lại vòng lặp

done:
    # In ra chuỗi đã được chuyển đổi
    li a7, 4                     
    la a0, buffer                
    ecall                       

exit:
    # Kết thúc chương trình
    li a7, 10                    
    ecall                     
