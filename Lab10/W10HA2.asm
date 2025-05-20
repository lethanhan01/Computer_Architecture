.eqv MONITOR_SCREEN 0x10010000   # Địa chỉ bắt đầu của bộ nhớ màn hình
.eqv RED          0x00FF0000    # Các giá trị màu thường sử dụng
.eqv GREEN        0x0000FF00
.eqv BLUE         0x000000FF
.eqv WHITE        0x00FFFFFF
.eqv YELLOW       0x00FFFF00
.eqv GREY         0xCCCCCCCC    # Màu xám

.text 
	# Khởi tạo các biến
	li t1, 0                    # Con trỏ pixel (đếm số ô đã xử lý)
	li a0, MONITOR_SCREEN       # Địa chỉ cơ sở của màn hình
	li s1, 2                    # Hằng số 2 dùng để kiểm tra chẵn/lẻ
	li s2, 8                    # Kích thước bàn cờ (8x8)
	li s3, 1                    # Biến đếm hàng (row), bắt đầu từ 1

# Vòng lặp chính - duyệt qua các hàng
loop2:
	bgt s3, s2, end            # Nếu đã xử lý hết 8 hàng thì kết thúc
	
	li s4, 1                   # Biến đếm cột (column), bắt đầu từ 1

# Vòng lặp con - duyệt qua các cột trong hàng hiện tại
loop1:  
	bgt s4, s2, tiep           # Nếu đã xử lý hết 8 cột thì chuyển sang hàng tiếp theo
	
	slli t2, t1, 2             # Tính offset bộ nhớ: t2 = t1 * 4 (mỗi pixel 4 byte)
	add t2, t2, a0             # t2 = địa chỉ pixel hiện tại (a0 + offset)
	
	# Xác định màu cho ô hiện tại (trắng hoặc xám)
	add s5, s3, s4             # Tính tổng chỉ số hàng và cột
	rem s5, s5, s1             # Lấy phần dư khi chia cho 2 (kiểm tra chẵn/lẻ)
	beq s5, zero, white        # Nếu chẵn (tổng hàng + cột chia hết cho 2) -> màu trắng

# Trường hợp ô màu xám
grey:  
	li t0, GREY                # Nạp màu xám
	sw t0, 0(t2)               # Lưu màu vào vị trí pixel hiện tại

# Tiếp tục xử lý ô tiếp theo
continue: 
	addi t1, t1, 1             # Tăng con trỏ pixel
	addi s4, s4, 1             # Tăng biến đếm cột
	j loop1                    # Lặp lại vòng lặp cột

# Trường hợp ô màu trắng
white:
	li t0, WHITE               # Nạp màu trắng
	sw t0, 0(t2)               # Lưu màu vào vị trí pixel hiện tại
	j continue                 # Quay lại tiếp tục vòng lặp

# Chuyển sang hàng tiếp theo
tiep: 
	addi s3, s3, 1             # Tăng biến đếm hàng
	j loop2                    # Lặp lại vòng lặp hàng

# Kết thúc chương trình
end:  
	li a7, 10                  # Gọi hệ thống để kết thúc chương trình
	ecall