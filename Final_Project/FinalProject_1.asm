# Địa chỉ các thiết bị ngoại vi
.eqv MONITOR_SCREEN 0x10010000  # Địa chỉ bắt đầu của bộ nhớ màn hình
.eqv KEY_CODE       0xFFFF0004   # Địa chỉ chứa mã ASCII của phím vừa được nhấn
.eqv KEY_READY      0xFFFF0000   # Địa chỉ báo phím đã sẵn sàng
.eqv DISPLAY_CODE   0xFFFF000C   # Địa chỉ xuất ký tự ra màn hình console
.eqv DISPLAY_READY  0xFFFF0008   # Địa chỉ báo màn hình console đã sẵn sàng

# Màu sắc
.eqv BLACK          0x00000000   # Màu đen (màu nền)
.eqv RED            0x00FF0000   # Màu đỏ
.eqv YELLOW         0x00FFFF00   # Màu vàng

# Các hằng số khác
.eqv SCREEN_WIDTH   512          # Chiều rộng màn hình
.eqv SCREEN_HEIGHT  512          # Chiều cao màn hình

.data
# Lưu trữ thông tin quả bóng
ball_x:        .word 256         # Tọa độ x của tâm quả bóng (giữa màn hình)
ball_y:        .word 256         # Tọa độ y của tâm quả bóng (giữa màn hình)
ball_radius:   .word 20          # Bán kính của quả bóng
ball_dx:       .word 0           # Vận tốc theo trục x (bắt đầu với 0)
ball_dy:       .word 0           # Vận tốc theo trục y (bắt đầu với 0)
ball_speed:    .word 1           # Tốc độ di chuyển của bóng

# Mảng lưu các điểm để vẽ hình tròn (được sử dụng bởi thuật toán Midpoint Circle)
circle_points: .space 168         # Để lưu các điểm tính toán (42 từ * 4 byte)
point_count:   .word 0           # Số điểm đã tính toán trong hình tròn

.text
MAIN:
    # Khởi tạo màn hình và vẽ quả bóng lần đầu
    jal init_screen
    jal draw_ball
    
    # Khởi tạo các thanh ghi lưu trữ địa chỉ I/O
    li s0, KEY_CODE
    li s1, KEY_READY
    li s2, DISPLAY_CODE
    li s3, DISPLAY_READY
    
    # Bộ đếm chu kỳ và tốc độ
    li s4, 0                   # Bộ đếm chu kỳ
    lw s5, ball_speed          # Tốc độ di chuyển hiện tại
    li s6, 100                 # Tốc độ cập nhật (chu kỳ delay)
    li s7, 0                   # Khởi tạo thanh ghi s7 (dùng cho kiểm soát tốc độ)

game_loop:
    # Tăng bộ đếm chu kỳ
    addi s4, s4, 1
    
    # Kiểm tra xem có phím được nhấn không
    lw t0, 0(s1)               # t0 = KEY_READY
    bnez t0, process_key       # Nếu có phím được nhấn, xử lý phím
    
check_update:
    # Kiểm tra xem đã đến lúc cập nhật vị trí bóng chưa
    blt s4, s6, game_loop      # Nếu chưa đủ chu kỳ, tiếp tục vòng lặp
    
    # Reset bộ đếm chu kỳ
    li s4, 0
    
    # Cập nhật vị trí bóng và vẽ lại
    jal update_ball_position
    
    # Tiếp tục vòng lặp chính
    j game_loop

# Xử lý khi có phím được nhấn
process_key:
    # Đọc mã ASCII của phím
    lw t0, 0(s0)               # t0 = KEY_CODE
    
    # Xử lý phím 'w' hoặc 'W' (di chuyển lên)
    li t1, 0x77                # ASCII 'w'
    beq t0, t1, move_up
    li t1, 0x57                # ASCII 'W'
    beq t0, t1, move_up
    
    # Xử lý phím 's' hoặc 'S' (di chuyển xuống)
    li t1, 0x73                # ASCII 's'
    beq t0, t1, move_down
    li t1, 0x53                # ASCII 'S'
    beq t0, t1, move_down
    
    # Xử lý phím 'a' hoặc 'A' (di chuyển sang trái)
    li t1, 0x61                # ASCII 'a'
    beq t0, t1, move_left
    li t1, 0x41                # ASCII 'A'
    beq t0, t1, move_left
    
    # Xử lý phím 'd' hoặc 'D' (di chuyển sang phải)
    li t1, 0x64                # ASCII 'd'
    beq t0, t1, move_right
    li t1, 0x44                # ASCII 'D'
    beq t0, t1, move_right
    
    # Xử lý phím 'z' hoặc 'Z' (tăng tốc độ)
    li t1, 0x7A                # ASCII 'z'
    beq t0, t1, increase_speed
    li t1, 0x5A                # ASCII 'Z'
    beq t0, t1, increase_speed
    
    # Xử lý phím 'x' hoặc 'X' (giảm tốc độ)
    li t1, 0x78                # ASCII 'x'
    beq t0, t1, decrease_speed
    li t1, 0x58                # ASCII 'X'
    beq t0, t1, decrease_speed
    
    # Nếu không phải các phím trên, quay lại vòng lặp chính
    j check_update

# Điều chỉnh vector vận tốc theo các phím
move_up:
    la t0, ball_dy
    li t1, -1
    sw t1, 0(t0)               # Đặt dy = -1 (di chuyển lên)
    j display_key

move_down:
    la t0, ball_dy
    li t1, 1
    sw t1, 0(t0)               # Đặt dy = 1 (di chuyển xuống)
    j display_key

move_left:
    la t0, ball_dx
    li t1, -1
    sw t1, 0(t0)               # Đặt dx = -1 (di chuyển sang trái)
    j display_key

move_right:
    la t0, ball_dx
    li t1, 1
    sw t1, 0(t0)               # Đặt dx = 1 (di chuyển sang phải)
    j display_key

# Điều chỉnh tốc độ của bóng
increase_speed:
    # Tăng tốc độ di chuyển
    la t0, ball_speed
    lw t1, 0(t0)
    addi t1, t1, 1             # Tăng ball_speed lên 1
    li t2, 5                   # Giới hạn tốc độ tối đa
    bge t1, t2, speed_max
    sw t1, 0(t0)               # Cập nhật ball_speed
    j adjust_delay

speed_max:
    li t1, 5
    sw t1, 0(t0)               # Giới hạn tốc độ tối đa là 5
    
adjust_delay:
    # Giảm chu kỳ cập nhật để bóng di chuyển nhanh hơn
    addi s6, s6, -10           # Giảm chu kỳ = tăng tốc độ
    li t0, 10                  # Chu kỳ tối thiểu
    bge s6, t0, display_key    # Nếu s6 >= 10, không cần điều chỉnh
    li s6, 10                  # Giới hạn chu kỳ tối thiểu
    j display_key

decrease_speed:
    # Giảm tốc độ di chuyển
    la t0, ball_speed
    lw t1, 0(t0)
    addi t1, t1, -1            # Giảm ball_speed xuống 1
    li t2, 1                   # Giới hạn tốc độ tối thiểu
    ble t1, t2, speed_min
    sw t1, 0(t0)               # Cập nhật ball_speed
    j adjust_delay_up

speed_min:
    li t1, 1
    sw t1, 0(t0)               # Giới hạn tốc độ tối thiểu là 1
    
adjust_delay_up:
    # Tăng chu kỳ cập nhật để bóng di chuyển chậm hơn
    addi s6, s6, 10            # Tăng chu kỳ = giảm tốc độ
    li t0, 200                 # Chu kỳ tối đa
    ble s6, t0, display_key    # Nếu s6 <= 200, không cần điều chỉnh
    li s6, 200                 # Giới hạn chu kỳ tối đa
    j display_key

# Hiển thị phím đã nhấn trên console (tùy chọn)
display_key:
    # Chờ đến khi console sẵn sàng
    display_wait:
        lw t1, 0(s3)           # t1 = DISPLAY_READY
        beqz t1, display_wait  # Nếu chưa sẵn sàng, tiếp tục chờ
    
    # Hiển thị phím
    sw t0, 0(s2)               # Ghi mã ASCII ra console
    
    # Quay lại kiểm tra cập nhật
    j check_update

# Cập nhật vị trí của bóng
update_ball_position:
    # Lưu địa chỉ trở về
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Xóa bóng ở vị trí cũ
    jal erase_ball
    
    # Cập nhật tọa độ dựa trên vector vận tốc
    la t0, ball_x
    lw t1, 0(t0)              # t1 = ball_x
    lw t2, ball_dx            # t2 = ball_dx
    lw t3, ball_speed         # t3 = ball_speed
    mul t2, t2, t3            # t2 = dx * speed
    add t1, t1, t2            # t1 = ball_x + dx*speed
    sw t1, 0(t0)              # Cập nhật ball_x
    
    la t0, ball_y
    lw t1, 0(t0)              # t1 = ball_y
    lw t2, ball_dy            # t2 = ball_dy
    lw t3, ball_speed         # t3 = ball_speed
    mul t2, t2, t3            # t2 = dy * speed
    add t1, t1, t2            # t1 = ball_y + dy*speed
    sw t1, 0(t0)              # Cập nhật ball_y
    
    # Kiểm tra va chạm với cạnh màn hình
    jal check_collision
    
    # Vẽ bóng ở vị trí mới
    jal draw_ball
    
    # Khôi phục địa chỉ trở về và return
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

# Kiểm tra va chạm với cạnh màn hình
check_collision:
    # Kiểm tra va chạm với cạnh trái
    la t0, ball_x
    lw t1, 0(t0)               # t1 = ball_x
    lw t2, ball_radius         # t2 = ball_radius
    ble t1, t2, bounce_left    # Nếu ball_x <= ball_radius, đã chạm cạnh trái
    
    # Kiểm tra va chạm với cạnh phải
    li t3, SCREEN_WIDTH
    sub t3, t3, t2             # t3 = SCREEN_WIDTH - ball_radius
    bge t1, t3, bounce_right   # Nếu ball_x >= SCREEN_WIDTH - ball_radius, đã chạm cạnh phải
    
    # Kiểm tra va chạm với cạnh trên
    la t0, ball_y
    lw t1, 0(t0)               # t1 = ball_y
    lw t2, ball_radius         # t2 = ball_radius
    ble t1, t2, bounce_top     # Nếu ball_y <= ball_radius, đã chạm cạnh trên
    
    # Kiểm tra va chạm với cạnh dưới
    li t3, SCREEN_HEIGHT
    sub t3, t3, t2             # t3 = SCREEN_HEIGHT - ball_radius
    bge t1, t3, bounce_bottom  # Nếu ball_y >= SCREEN_HEIGHT - ball_radius, đã chạm cạnh dưới
    
    # Nếu không có va chạm, return
    jr ra

# Xử lý va chạm với các cạnh
bounce_left:
    # Đặt lại tọa độ x để không vượt quá cạnh
    la t0, ball_x
    lw t1, ball_radius
    sw t1, 0(t0)
    
    # Đảo hướng di chuyển theo trục x
    la t0, ball_dx
    lw t1, 0(t0)
    neg t1, t1                 # t1 = -t1
    sw t1, 0(t0)
    
    jr ra

bounce_right:
    # Đặt lại tọa độ x để không vượt quá cạnh
    la t0, ball_x
    li t1, SCREEN_WIDTH
    lw t2, ball_radius
    sub t1, t1, t2             # t1 = SCREEN_WIDTH - ball_radius
    sw t1, 0(t0)
    
    # Đảo hướng di chuyển theo trục x
    la t0, ball_dx
    lw t1, 0(t0)
    neg t1, t1                 # t1 = -t1
    sw t1, 0(t0)
    
    jr ra

bounce_top:
    # Đặt lại tọa độ y để không vượt quá cạnh
    la t0, ball_y
    lw t1, ball_radius
    sw t1, 0(t0)
    
    # Đảo hướng di chuyển theo trục y
    la t0, ball_dy
    lw t1, 0(t0)
    neg t1, t1                 # t1 = -t1
    sw t1, 0(t0)
    
    jr ra

bounce_bottom:
    # Đặt lại tọa độ y để không vượt quá cạnh
    la t0, ball_y
    li t1, SCREEN_HEIGHT
    lw t2, ball_radius
    sub t1, t1, t2             # t1 = SCREEN_HEIGHT - ball_radius
    sw t1, 0(t0)
    
    # Đảo hướng di chuyển theo trục y
    la t0, ball_dy
    lw t1, 0(t0)
    neg t1, t1                 # t1 = -t1
    sw t1, 0(t0)
    
    jr ra

# Vẽ quả bóng trên màn hình
draw_ball:
    # Lưu địa chỉ trở về
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Tính toán các điểm trong hình tròn
    jal calculate_circle_points
    
    # Vẽ các điểm
    lw a0, ball_x              # a0 = ball_x
    lw a1, ball_y              # a1 = ball_y
    lw a2, ball_radius         # a2 = ball_radius
    li a3, YELLOW              # a3 = color (yellow)
    jal draw_circle
    
    # Khôi phục địa chỉ trở về và return
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

# Xóa quả bóng từ màn hình
erase_ball:
    # Lưu địa chỉ trở về
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Tính toán các điểm trong hình tròn
    jal calculate_circle_points
    
    # Xóa các điểm (vẽ với màu đen)
    lw a0, ball_x              # a0 = ball_x
    lw a1, ball_y              # a1 = ball_y
    lw a2, ball_radius         # a2 = ball_radius
    li a3, BLACK               # a3 = color (black)
    jal draw_circle
    
    # Khôi phục địa chỉ trở về và return
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

# Khởi tạo màn hình (làm sạch màn hình)
init_screen:
    li t0, MONITOR_SCREEN      # Địa chỉ bắt đầu của màn hình
    li t3, 512
    addi t2, zero, 512        # t2 = SCREEN_HEIGHT
    mul t1, t1, t2            # t1 = SCREEN_WIDTH * SCREEN_HEIGHT
    li t2, BLACK               # Màu đen
    
clear_screen_loop:
    sw t2, 0(t0)               # Đặt màu hiện tại thành đen
    addi t0, t0, 4             # Chuyển đến pixel tiếp theo
    addi t1, t1, -1            # Giảm số lượng pixel còn lại
    bnez t1, clear_screen_loop # Nếu còn pixel, tiếp tục vòng lặp
    
    jr ra 

# Thuật toán Midpoint Circle để tính toán các điểm của hình tròn
calculate_circle_points:
    # Khởi tạo mảng lưu các điểm của hình tròn
    la t0, circle_points
    
    # Thuật toán Midpoint Circle
    lw t1, ball_radius         # t1 = r (bán kính)
    li t2, 0                   # t2 = x
    add t3, t1, zero           # t3 = y
    li t4, 1                   # t4 = 1 - r
    
    # Khởi tạo bộ đếm điểm
    li t5, 0                   # t5 = số điểm đã tính
    
    # Lưu điểm đầu tiên
    sw t2, 0(t0)               # circle_points[0] = x
    sw t3, 4(t0)               # circle_points[1] = y
    addi t0, t0, 8
    addi t5, t5, 1             # Tăng bộ đếm điểm
    
midpoint_circle_loop:
    addi t2, t2, 1             # x = x + 1
    
    # Nếu d < 0 thì d = d + 4*x + 6
    bgez t4, midpoint_else
    slli t6, t2, 2             # t6 = 4*x
    addi t6, t6, 6             # t6 = 4*x + 6
    add t4, t4, t6             # d = d + 4*x + 6
    j midpoint_next
    
midpoint_else:
    # Nếu d >= 0 thì d = d + 4*(x - y) + 10 và y = y - 1
    addi t3, t3, -1            # y = y - 1
    sub t6, t2, t3             # t6 = x - y
    slli t6, t6, 2             # t6 = 4*(x - y)
    addi t6, t6, 10            # t6 = 4*(x - y) + 10
    add t4, t4, t6             # d = d + 4*(x - y) + 10
    
midpoint_next:
    # Lưu điểm hiện tại
    sw t2, 0(t0)               # circle_points[i] = x
    sw t3, 4(t0)               # circle_points[i+1] = y
    addi t0, t0, 8
    addi t5, t5, 1             # Tăng bộ đếm điểm
    
    # Điều kiện dừng vòng lặp: x < y
    blt t2, t3, midpoint_circle_loop
    
    # Lưu số điểm đã tính toán
    la t0, point_count
    sw t5, 0(t0)
    
    jr ra

# Vẽ hình tròn với các điểm đã tính toán
draw_circle:
    # a0 = tọa độ x của tâm
    # a1 = tọa độ y của tâm
    # a2 = bán kính (không dùng trong hàm này)
    # a3 = màu
    
    # Lưu thanh ghi
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    
    add s0, a0, zero           # s0 = centerX
    add s1, a1, zero           # s1 = centerY
    add s2, a3, zero           # s2 = color
    
    # Duyệt qua các điểm đã tính toán
    la t0, circle_points
    lw t1, point_count         # t1 = số điểm đã tính toán
    li t2, 0                   # t2 = i (chỉ số của điểm)
    
draw_circle_loop:
    # Kiểm tra điều kiện dừng
    beq t2, t1, draw_circle_end
    
    # Lấy tọa độ x và y của điểm hiện tại
    lw t3, 0(t0)               # t3 = x
    lw t4, 4(t0)               # t4 = y
    
    # Tính toán và vẽ 8 điểm đối xứng qua tâm
    add a0, s0, t3             # a0 = centerX + x
    add a1, s1, t4             # a1 = centerY + y
    add a2, s2, zero           # a2 = color
    jal plot_pixel
    
    add a0, s0, t3             # a0 = centerX + x
    sub a1, s1, t4             # a1 = centerY - y
    jal plot_pixel
    
    sub a0, s0, t3             # a0 = centerX - x
    add a1, s1, t4             # a1 = centerY + y
    jal plot_pixel
    
    sub a0, s0, t3             # a0 = centerX - x
    sub a1, s1, t4             # a1 = centerY - y
    jal plot_pixel
    
    add a0, s0, t4             # a0 = centerX + y
    add a1, s1, t3             # a1 = centerY + x
    jal plot_pixel
    
    add a0, s0, t4             # a0 = centerX + y
    sub a1, s1, t3             # a1 = centerY - x
    jal plot_pixel
    
    sub a0, s0, t4             # a0 = centerX - y
    add a1, s1, t3             # a1 = centerY + x
    jal plot_pixel
    
    sub a0, s0, t4             # a0 = centerX - y
    sub a1, s1, t3             # a1 = centerY - x
    jal plot_pixel
    
    # Chuyển đến điểm tiếp theo
    addi t0, t0, 8             # Địa chỉ điểm tiếp theo
    addi t2, t2, 1             # i = i + 1
    
    j draw_circle_loop
    
draw_circle_end:
    # Khôi phục thanh ghi và return
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 16
    jr ra

# Vẽ một pixel tại tọa độ (x, y) với màu được chỉ định
plot_pixel:
    # a0 = x
    # a1 = y
    # a2 = color
    
    # Kiểm tra xem tọa độ có nằm trong màn hình không
    blt a0, zero, plot_end      # Nếu x < 0, không vẽ
    blt a1, zero, plot_end      # Nếu y < 0, không vẽ
    li t0, SCREEN_WIDTH
    bge a0, t0, plot_end        # Nếu x >= SCREEN_WIDTH, không vẽ
    li t0, SCREEN_HEIGHT
    bge a1, t0, plot_end        # Nếu y >= SCREEN_HEIGHT, không vẽ
plot_end: 
    # Tính địa chỉ của pixel: address = base_address + 4*(y*width + x)
    li t1, SCREEN_WIDTH
    mul t1, t1, a1        # t1 = SCREEN_WIDTH * y
    add t1, t1, a0        # t1 = t1 + x
    slli t1, t1, 2        # t1 = t1 * 4
    li t0, MONITOR_SCREEN
    add t0, t0, t1        # t0 = địa chỉ pixel
    sw a2, 0(t0)          # vẽ màu a2
