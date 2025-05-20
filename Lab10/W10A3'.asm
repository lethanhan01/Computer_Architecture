.data
BASE_ADDR: .word 0x10040000
WIDTH:     .word 128
RED:       .word 0x00FF0000     # Màu đỏ
YELLOW:    .word 0x00FFFF00     # Màu vàng

# Danh sách 10 đỉnh (x, y) ngôi sao vàng
star_points:
    .word 64,34   # 0
    .word 70,54   # 1
    .word 91,54   # 2
    .word 74,67   # 3
    .word 80,87   # 4
    .word 64,74   # 5
    .word 48,87   # 6
    .word 54,67   # 7
    .word 37,54   # 8
    .word 58,54   # 9

.text
.globl _start
_start:
    # Load base address
    la x5, BASE_ADDR
    lw x6, 0(x5)       # x6 = base address
    li x7, 128         # x7 = WIDTH
    li x8, 0x00FF0000  # x8 = màu đỏ
    li x9, 0x00FFFF00  # x9 = màu vàng

# --- Tô nền đỏ ---
    li x10, 0          # y
fill_row:
    li x11, 0          # x
fill_col:
    mul x12, x10, x7   # y * WIDTH
    add x12, x12, x11  # offset = y * W + x
    slli x13, x12, 2   # offset *= 4
    add x14, x6, x13   # addr = base + offset
    sw x8, 0(x14)      # lưu màu đỏ
    addi x11, x11, 1
    blt x11, x7, fill_col
    addi x10, x10, 1
    blt x10, x7, fill_row

# --- Vẽ ngôi sao ---
    la x15, star_points
    li x16, 0              # i = 0
draw_star_loop:
    li x17, 10
    addi x18, x16, 1
    rem x18, x18, x17      # j = (i+1) % 10

    slli x19, x16, 3       # offset_i = i * 8
    slli x20, x18, 3       # offset_j = j * 8

    add x21, x15, x19
    lw a0, 0(x21)          # x1
    lw a1, 4(x21)          # y1

    add x22, x15, x20
    lw a2, 0(x22)          # x2
    lw a3, 4(x22)          # y2

    jal ra, draw_line

    addi x16, x16, 1
    blt x16, x17, draw_star_loop

hang:
    j hang

# --- Hàm vẽ đoạn thẳng: draw_line(x1,y1,x2,y2) ---
draw_line:
    sub x23, a2, a0
    bge x23, x0, dx_ok
    neg x23, x23
dx_ok:
    mv x24, x23           # dx

    sub x25, a3, a1
    bge x25, x0, dy_ok
    neg x25, x25
dy_ok:
    mv x26, x25           # dy

    li x27, 1
    blt a0, a2, sx_ok
    li x27, -1
sx_ok:
    li x28, 1
    blt a1, a3, sy_ok
    li x28, -1
sy_ok:

    sub x29, x24, x26     # err = dx - dy

draw_line_loop:
    # addr = base + ((y * width + x) * 4)
    mul x30, a1, x7
    add x30, x30, a0
    slli x30, x30, 2
    add x31, x6, x30
    sw x9, 0(x31)

    beq a0, a2, check_y
    j continue_line
check_y:
    beq a1, a3, draw_ret
continue_line:
    slli x5, x29, 1
    bge x5, x0, step_x
    j step_y
step_x:
    sub x29, x29, x26
    add a0, a0, x27
step_y:
    blt x5, x24, skip_err
    sub x29, x29, x24
    add a1, a1, x28
skip_err:
    j draw_line_loop

draw_ret:
    ret
