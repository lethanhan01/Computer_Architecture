.eqv KEY_CODE 0xFFFF0004 # ASCII code from keyboard, 1 byte
.eqv KEY_READY 0xFFFF0000 # =1 if has a new keycode ?
 # Auto clear after lw
.eqv DISPLAY_CODE 0xFFFF000C # ASCII code to show, 1 byte
.eqv DISPLAY_READY 0xFFFF0008 # =1 if the display has already to do
.eqv MONITOR_SCREEN 0x10010000 # Dia chi bat dau cua bo nho man hinh
.eqv YELLOW 0x00FFFF00
.eqv BLACK 0x00000000
.eqv WIDTH 512
 # Auto clear after sw
.text
 li a3,0 # danh dau huong cua hinh tron dang chay -2 : tren,-1 : trai,1 : phai,2 : duoi
 li s7,1
 li s3,16 #R
 li s4,512 
 li a2,MONITOR_SCREEN
 li s8,65
 li s9,68
 li s10,83
 li s11,87
 li a6,88 
 li a7,90
 li a0, KEY_CODE
 li a1, KEY_READY
 li s0, DISPLAY_CODE
 li t6, DISPLAY_READY
 li s1,256 #toa do cua x
 li s2,256 #toa do cua y
loop:
WaitForKey:
 lw t1, 0(a1) # t1 = [a1] = KEY_READY
 beq t1, zero, WaitForKey # if t1 == 0 then Polling
ReadKey:
 lw t0, 0(a0) # t0 = [a0] = KEY_CODE
 beq t0,s8,go_left
 beq t0,s9,go_right
 beq t0,s10,go_down
 beq t0,s11,go_up
 beq t0,a6,up_speed
 beq t0,a7,down_speed
WaitForDis:
 lw t2, 0(t6) # t2 = [s1] = DISPLAY_READY
 beq t2, zero, WaitForDis # if t2 == 0 then polling
Encrypt:
 # Sang trai
go_left:
 addi sp,sp,-4
 sw t1,0(sp)
 li a3, -1             # cập nhật hướng
 mv t5, s3             # t5 = bán kính
 sub t1, s1, s7        # t1 = s1 + s7     # t1 = vị trí sau khi đi trái
 blt t1, t5, set_to_go_right  # nếu đi vượt trái màn hình thì quay lại
 sub t5,s4,s3
 bge t1,t5,set_to_go_right
 jal paint_black
 mv s1, t1             # cập nhật s1
 jal paint_yellow
 lw t1,0(sp)
 addi sp,sp,4
 j ReadKey
 # Sang  phai
go_right:
 addi sp,sp,-4
 sw t1,0(sp)
 li a3, 1
 sub t5, s4, s3            # t5 = WIDTH - R
 add t1, s1, s7
 bge t1, t5, set_to_go_left
 mv t5,s3
 blt t1,t5, set_to_go_left
 jal paint_black
 mv s1, t1
 jal paint_yellow
 lw t1, 0(sp)
 addi sp, sp, 4
 j ReadKey
 # Xuong duoi
go_down:
 addi sp, sp, -4
 sw t1, 0(sp)
 li a3, 2                     # hướng xuống
 sub t5, s4, s3               # t5 = HEIGHT - R = 512 - R
 add t1, s2, s7            # t1 = s2 + s7 + 1
 bge t1, t5, set_to_go_up     # nếu vượt biên dưới thì đổi hướng
 mv t5,s3
 blt t1,t5, set_to_go_up
 jal paint_black
 mv s2, t1                    # cập nhật y
 jal paint_yellow
 lw t1, 0(sp)
 addi sp, sp, 4
 j ReadKey
 # Len tren
go_up:
 addi sp, sp, -4
 sw t1, 0(sp)
 li a3, -2                    # hướng lên
 mv t5, s3                    # t5 = R
 sub t1, s2, s7             # t1 = s2 + s7 - 1
 blt t1, t5, set_to_go_down   # nếu vượt biên trên thì đổi hướng
 sub t5,s4,s3
 bge t1,t5,set_to_go_down
 jal paint_black
 mv s2, t1                    # cập nhật y
 jal paint_yellow
 lw t1, 0(sp)
 addi sp, sp, 4
 j ReadKey
ShowKey:
 j loop
set_to_go_up:
 li t0,87
 sw t0,0(a0)
 j ReadKey
set_to_go_left:
 li t0,65
 sw t0,0(a0)
 j ReadKey
set_to_go_right:
 li t0,68
 sw t0,0(a0)
 j ReadKey
set_to_go_down:
 li t0,83
 sw t0,0(a0)
 j ReadKey
###################################
#####PaintFuntion##################
###################################
paint_yellow:
 addi sp, sp, -56       # Cấp 64 byte stack (14 thanh ghi x 4 byte)
 sw ra, 52(sp)          # Lưu địa chỉ trả về
 sw a0, 48(sp)
 sw a4, 44(sp)
 sw a5, 40(sp)
 sw s3, 36(sp)
 sw s4, 32(sp)
 sw s5, 28(sp)
 sw s6, 24(sp)
 sw s7, 20(sp)
 sw t0, 16(sp)
 sw t3, 12(sp)
 sw t4, 8(sp)
 sw t5, 4(sp)
 sw t6, 0(sp)
 li a4,0 #t1
 mv a5,s3 #R #t2
 slli t3,a5,1 # 2*R
 li t4,3
 sub t5,t4,t3 # 3-2*R
 li t6,WIDTH
 li a0,MONITOR_SCREEN
 print_yellow:
 blt a5,a4,end_of_print_yellow
 add s3,s2,a5 # y0+y
 mul s4,s3,t6 #(y0+y)*512
 add s5,s1,a4 #x0+x
 add s6,s4,s5 #(y0+y)*512+(x0+x)
 slli s6,s6,2 #((y0+y)*512+(x0+x))*4
 add s7,s6,a0
 li t0,YELLOW
 sw t0,0(s7)
 add s3,s2,a5 # y0+y
 mul s4,s3,t6 #(y0+y)*512
 sub s5,s1,a4 #x0-x
 add s6,s4,s5 #(y0+y)*512+(x0-x)
 slli s6,s6,2 #((y0+y)*512+(x0-x))*4
 add s7,s6,a0
 li t0,YELLOW
 sw t0,0(s7)
 sub s3,s2,a5 # y0-y
 mul s4,s3,t6 #(y0-y)*512
 add s5,s1,a4 #x0+x
 add s6,s4,s5 #(y0-y)*512+(x0+x)
 slli s6,s6,2 #((y0-y)*512+(x0+x))*4
 add s7,s6,a0
 li t0,YELLOW
 sw t0,0(s7)
 sub s3,s2,a5 # y0-y
 mul s4,s3,t6 #(y0-y)*512
 sub s5,s1,a4 #x0-x
 add s6,s4,s5 #(y0-y)*512+(x0-x)
 slli s6,s6,2 #((y0-y)*512+(x0-x))*4
 add s7,s6,a0
 li t0,YELLOW
 sw t0,0(s7)
 add s3,s2,a4 # y0+x
 mul s4,s3,t6 #(y0+x)*512
 add s5,s1,a5 #x0+y
 add s6,s4,s5 #(y0+x)*512+(x0+y)
 slli s6,s6,2 #((y0+x)*512+(x0+y))*4
 add s7,s6,a0
 li t0,YELLOW
 sw t0,0(s7)
 add s3,s2,a4 # y0+x
 mul s4,s3,t6 #(y0+x)*512
 sub s5,s1,a5 #x0-y
 add s6,s4,s5 #(y0+x)*512+(x0-y)
 slli s6,s6,2 #((y0+x)*512+(x0+y))*4
 add s7,s6,a0
 li t0,YELLOW
 sw t0,0(s7)
 sub s3,s2,a4 # y0-x
 mul s4,s3,t6 #(y0-x)*512
 add s5,s1,a5 #x0+y
 add s6,s4,s5 #(y0+x)*512+(x0+y)
 slli s6,s6,2 #((y0+x)*512+(x0+y))*4
 add s7,s6,a0
 li t0,YELLOW
 sw t0,0(s7)
 sub s3,s2,a4 # y0-x
 mul s4,s3,t6 #(y0-x)*512
 sub s5,s1,a5 #x0-y
 add s6,s4,s5 #(y0-x)*512+(x0-y)
 slli s6,s6,2 #((y0-x)*512+(x0-y))*4
 add s7,s6,a0
 li t0,YELLOW
 sw t0,0(s7)
 bge zero,t5,xuli1
 sub s5,a4,a5
 slli s5,s5,2
 add t5,t5,s5
 addi t5,t5,10
 addi a5,a5,-1
 j continue1
 xuli1:
 slli s6,a4,2
 add t5,t5,s6
 addi t5,t5,6
 continue1:
 addi a4,a4,1
 j print_yellow
 end_of_print_yellow:
 lw ra, 52(sp)
 lw a0, 48(sp)
 lw a4, 44(sp)
 lw a5, 40(sp)
 lw s3, 36(sp)
 lw s4, 32(sp)
 lw s5, 28(sp)
 lw s6, 24(sp)
 lw s7, 20(sp)
 lw t0, 16(sp)
 lw t3, 12(sp)
 lw t4, 8(sp)
 lw t5, 4(sp)
 lw t6, 0(sp)
 addi sp, sp, 56
 jr ra


paint_black:
 addi sp, sp, -56     # Cấp 64 byte stack (16 thanh ghi x 4 byte)
 sw ra, 52(sp)          # Lưu địa chỉ trả về
 sw a0, 48(sp)
 sw a4, 44(sp)
 sw a5, 40(sp)
 sw s3, 36(sp)
 sw s4, 32(sp)
 sw s5, 28(sp)
 sw s6, 24(sp)
 sw s7, 20(sp)
 sw t0, 16(sp)
 sw t3, 12(sp)
 sw t4, 8(sp)
 sw t5, 4(sp)
 sw t6, 0(sp)
 li a4,0 #t1
 mv a5,s3 #R #t2
 slli t3,a5,1 # 2*R
 li t4,3
 sub t5,t4,t3 # 3-2*R
 li t6,WIDTH
 li a0,MONITOR_SCREEN
 print_black:
 blt a5,a4,end_of_print_black
 add s3,s2,a5 # y0+y
 mul s4,s3,t6 #(y0+y)*512
 add s5,s1,a4 #x0+x
 add s6,s4,s5 #(y0+y)*512+(x0+x)
 slli s6,s6,2 #((y0+y)*512+(x0+x))*4
 add s7,s6,a0
 li t0,BLACK
 sw t0,0(s7)
 add s3,s2,a5 # y0+y
 mul s4,s3,t6 #(y0+y)*512
 sub s5,s1,a4 #x0-x
 add s6,s4,s5 #(y0+y)*512+(x0-x)
 slli s6,s6,2 #((y0+y)*512+(x0-x))*4
 add s7,s6,a0
 li t0,BLACK
 sw t0,0(s7)
 sub s3,s2,a5 # y0-y
 mul s4,s3,t6 #(y0-y)*512
 add s5,s1,a4 #x0+x
 add s6,s4,s5 #(y0-y)*512+(x0+x)
 slli s6,s6,2 #((y0-y)*512+(x0+x))*4
 add s7,s6,a0
 li t0,BLACK
 sw t0,0(s7)
 sub s3,s2,a5 # y0-y
 mul s4,s3,t6 #(y0-y)*512
 sub s5,s1,a4 #x0-x
 add s6,s4,s5 #(y0-y)*512+(x0-x)
 slli s6,s6,2 #((y0-y)*512+(x0-x))*4
 add s7,s6,a0
 li t0,BLACK
 sw t0,0(s7)
 add s3,s2,a4 # y0+x
 mul s4,s3,t6 #(y0+x)*512
 add s5,s1,a5 #x0+y
 add s6,s4,s5 #(y0+x)*512+(x0+y)
 slli s6,s6,2 #((y0+x)*512+(x0+y))*4
 add s7,s6,a0
 li t0,BLACK
 sw t0,0(s7)
 add s3,s2,a4 # y0+x
 mul s4,s3,t6 #(y0+x)*512
 sub s5,s1,a5 #x0-y
 add s6,s4,s5 #(y0+x)*512+(x0-y)
 slli s6,s6,2 #((y0+x)*512+(x0+y))*4
 add s7,s6,a0
 li t0,BLACK
 sw t0,0(s7)
 sub s3,s2,a4 # y0-x
 mul s4,s3,t6 #(y0-x)*512
 add s5,s1,a5 #x0+y
 add s6,s4,s5 #(y0+x)*512+(x0+y)
 slli s6,s6,2 #((y0+x)*512+(x0+y))*4
 add s7,s6,a0
 li t0,BLACK
 sw t0,0(s7)
 sub s3,s2,a4 # y0-x
 mul s4,s3,t6 #(y0-x)*512
 sub s5,s1,a5 #x0-y
 add s6,s4,s5 #(y0-x)*512+(x0-y)
 slli s6,s6,2 #((y0-x)*512+(x0-y))*4
 add s7,s6,a0
 li t0,BLACK
 sw t0,0(s7)
 bge zero,t5,xuli2
 sub s5,a4,a5
 slli s5,s5,2
 add t5,t5,s5
 addi t5,t5,10
 addi a5,a5,-1
 j continue2
 xuli2:
 slli s6,a4,2
 add t5,t5,s6
 addi t5,t5,6
 continue2:
 addi a4,a4,1
 j print_black
 end_of_print_black:
 lw ra, 52(sp)
 lw a0, 48(sp)
 lw a4, 44(sp)
 lw a5, 40(sp)
 lw s3, 36(sp)
 lw s4, 32(sp)
 lw s5, 28(sp)
 lw s6, 24(sp)
 lw s7, 20(sp)
 lw t0, 16(sp)
 lw t3, 12(sp)
 lw t4, 8(sp)
 lw t5, 4(sp)
 lw t6, 0(sp)
 addi sp, sp, 56
 jr ra
 
 
 up_speed:
 addi s7,s7,1
 addi sp,sp,-16
 sw t6,12(sp)
 sw t5,8(sp)
 sw t4,4(sp)
 sw t3,0(sp)
 li t3,-2 #  tren
 li t4,-1 # trai
 li t5,1 # phai
 li t6,2 #duoi
 beq a3,t3,set_to_up1
 beq a3,t4,set_to_left1
 beq a3,t5,set_to_right1
 beq a3,t6,set_to_down1
 set_to_up1:
 li t0,83
 sw t0,0(a0)
 lw t6,12(sp)
 lw t5,8(sp)
 lw t4,4(sp)
 lw t3,0(sp)
 addi sp,sp,16
 j go_up
 set_to_down1:
 li t0,87
 sw t0,0(a0)
 lw t6,12(sp)
 lw t5,8(sp)
 lw t4,4(sp)
 lw t3,0(sp)
 addi sp,sp,16
 j go_down
 set_to_left1:
 li t0,65
 sw t0,0(a0)
 lw t6,12(sp)
 lw t5,8(sp)
 lw t4,4(sp)
 lw t3,0(sp)
 addi sp,sp,16
 j go_left
 set_to_right1:
 li t0,68
 sw t0,0(a0)
 lw t6,12(sp)
 lw t5,8(sp)
 lw t4,4(sp)
 lw t3,0(sp)
 addi sp,sp,16
 j go_right
 
 
 down_speed:
 addi s7,s7,-1
 blt s7,zero,stop
 addi sp,sp,-16
 sw t6,12(sp)
 sw t5,8(sp)
 sw t4,4(sp)
 sw t3,0(sp)
 li t3,-2 #  tren
 li t4,-1 # trai
 li t5,1 # phai
 li t6,2 #duoi
 beq a3,t3,set_to_up2
 beq a3,t4,set_to_left2
 beq a3,t5,set_to_right2
 beq a3,t6,set_to_down2
 set_to_up2:
 li t0,83
 sw t0,0(a0)
 lw t6,12(sp)
 lw t5,8(sp)
 lw t4,4(sp)
 lw t3,0(sp)
 addi sp,sp,16
 j go_up
 set_to_down2:
 li t0,87
 sw t0,0(a0)
 lw t6,12(sp)
 lw t5,8(sp)
 lw t4,4(sp)
 lw t3,0(sp)
 addi sp,sp,16
 j go_down
 set_to_left2:
 li t0,65
 sw t0,0(a0)
 lw t6,12(sp)
 lw t5,8(sp)
 lw t4,4(sp)
 lw t3,0(sp)
 addi sp,sp,16
 j go_left
 set_to_right2:
 li t0,68
 sw t0,0(a0)
 lw t6,12(sp)
 lw t5,8(sp)
 lw t4,4(sp)
 lw t3,0(sp)
 addi sp,sp,16
 j go_right  
stop:
 li s7,0
 j ReadKey