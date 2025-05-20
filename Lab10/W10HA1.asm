.eqv SEVENSEG_LEFT    0xFFFF0011    # Địa chỉ của đèn LED 7 đoạn bên trái
                                    #     Bit 0 = đoạn a 
                                    #     Bit 1 = đoạn b 
                                    #     ...    
                                    #     Bit 7 = dấu chấm 
.eqv SEVENSEG_RIGHT   0xFFFF0010    # Địa chỉ của đèn LED 7 đoạn bên phải

.data
# Mảng mã hiển thị cho các số từ 0-9 trên LED 7 đoạn (dạng Common Anode)
A: .word 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F 

.text 
main:  
    # Thiết lập tham số cho hệ thống
    li a7, 12                      # Số hiệu syscall để đọc số nguyên từ bàn phím
    li a6, 10                      # Hằng số 10 dùng để chia
    la t2, A                       # Tải địa chỉ bảng mã LED 7 đoạn
    
    li t1, 4                       # Kích thước mỗi phần tử trong mảng (4 byte)
    
    ecall                          # Đọc số từ bàn phím (kết quả lưu vào a0)
    
    # Xử lý chữ số hàng đơn vị (hiển thị trên LED bên phải)
    rem a2, a0, a6                 # Lấy chữ số hàng đơn vị (a0 % 10)
    div a0, a0, a6                 # Chia số cho 10 để lấy chữ số hàng chục
    mul a2, a2, t1                 # Tính offset trong mảng A (index * 4)
    add a2, a2, t2                 # Tính địa chỉ phần tử trong mảng A
    lw a1, 0(a2)                   # Lấy mã hiển thị cho chữ số này
    
    jal SHOW_7SEG_RIGHT            # Hiển thị chữ số hàng đơn vị trên LED phải
    
    # Xử lý chữ số hàng chục (hiển thị trên LED bên trái)
    rem a2, a0, a6                 # Lấy chữ số hàng chục (a0 % 10)
    div a0, a0, a6                 # Chia số cho 10 (ở đây chỉ để minh họa)
    mul a2, a2, t1                 # Tính offset trong mảng A
    add a2, a2, t2                 # Tính địa chỉ phần tử trong mảng A
    lw a1, 0(a2)                   # Lấy mã hiển thị cho chữ số này
    
    jal SHOW_7SEG_LEFT             # Hiển thị chữ số hàng chục trên LED trái
    
exit:       
    li a7, 10                      # Số hiệu syscall để kết thúc chương trình
    ecall  
end_main:  

# ---------------------------------------------------------------  
# Hàm SHOW_7SEG_LEFT: Bật/tắt các đoạn của LED 7 đoạn trái
# Tham số đầu vào:
#    a1 - Giá trị cần hiển thị (mã các đoạn)        
# Ghi chú: Thanh ghi t0 bị thay đổi  
# ---------------------------------------------------------------  
SHOW_7SEG_LEFT:    
    li t0, SEVENSEG_LEFT          # Gán địa chỉ thanh ghi điều khiển LED trái
    sb a1, 0(t0)                  # Ghi giá trị hiển thị vào cổng LED
    jr ra                         # Trở về từ hàm con

# ---------------------------------------------------------------  
# Hàm SHOW_7SEG_RIGHT: Bật/tắt các đoạn của LED 7 đoạn phải
# Tham số đầu vào:
#    a1 - Giá trị cần hiển thị (mã các đoạn)        
# Ghi chú: Thanh ghi t0 bị thay đổi  
# ---------------------------------------------------------------  
SHOW_7SEG_RIGHT:   
    li t0, SEVENSEG_RIGHT         # Gán địa chỉ thanh ghi điều khiển LED phải
    sb a1, 0(t0)                  # Ghi giá trị hiển thị vào cổng LED
    jr ra                         # Trở về từ hàm con