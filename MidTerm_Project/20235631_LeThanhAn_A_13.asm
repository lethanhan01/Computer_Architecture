.data
tamgiac:    .asciz "Đây là tam giác không cân\n"   
tamgiaccan: .asciz "Đây là tam giác cân\n"      
khongtamgiac: .asciz "Đây không phải là tam giác\n" 

.text
main:
    # Nhập cạnh a 
    li a7, 5           
    ecall              
    add s0, a0, zero   # Lưu giá trị a vào thanh ghi s0 
    
    # Nhập cạnh b
    li a7, 5
    ecall
    add s1, a0, zero   # Lưu giá trị b vào thanh ghi s1 
    
    # Nhập cạnh c
    li a7, 5
    ecall
    add s2, a0, zero   # Lưu giá trị c vào thanh ghi s2 

    # Kiểm tra các cạnh > 0
    ble s0, zero, C         # Nhảy đến nhãn C nếu a <= 0
    ble s1, zero, C         # Nhảy đến nhãn C nếu b <= 0
    ble s2, zero, C         # Nhảy đến nhãn C nếu c <= 0

    # Kiểm tra điều kiện tổng 2 cạnh > cạnh còn lại
    add t0, s0, s1     # t0 = a + b
    ble t0, s2, C      # Nhảy đến C nếu a + b <= c

    add t1, s1, s2     # t1 = b + c
    ble t1, s0, C      # Nhảy đến C nếu b + c <= a

    add t2, s2, s0     # t2 = c + a
    ble t2, s1, C      # Nhảy đến C nếu c + a <= b

    # Kiểm tra tam giác cân
    beq s0, s1, A      # Nhảy đến A nếu a == b
    beq s1, s2, A      # Nhảy đến A nếu b == c
    beq s2, s0, A      # Nhảy đến A nếu c == a

    la a0, tamgiac     # Địa chỉ thông báo tam giác thường vào a0
    j print            # Nhảy đến phần in kết quả

A:
    la a0, tamgiaccan  # Địa chỉ thông báo tam giác cân vào a0
    j print            # Nhảy đến phần in kết quả

C:
    la a0, khongtamgiac # Địa chỉ thông báo không phải tam giác vào a0
        
print:

    li a7, 4           # in chuỗi 
    ecall              

    li a7, 10          # thoát chương trình
    ecall              
