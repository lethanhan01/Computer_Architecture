.data
A:       .word 325, -1, 52, 1, 5, 74, -24, -2, 5, 1    # Mảng cần sắp xếp (10 phần tử) 
prompt:  .asciz " "       
space:   .asciz " "            # Khoảng trắng giữa các phần tử
newline: .asciz "\n"           # Xuống dòng

.text 
.globl main 
main: 
    # Khởi tạo: s0 = địa chỉ đầu mảng, s1 = số phần tử (10)
    la    s0, A               # s0 = địa chỉ của mảng A
    li    s1, 10              # s1 = số phần tử của mảng (10)

    # s2: chỉ số outer loop (i = 0)
    li    s2, 0               # s2 = 0 (bắt đầu từ phần tử đầu tiên)

outer_loop: 
    # Nếu i >= n-1 (10-1 = 9) -> kết thúc sắp xếp
    li    t0, 9               # t0 = 9 (n-1)
    bge   s2, t0, sort_done   # Nếu s2 >= t0, nhảy đến sort_done

    # s3: chỉ số inner loop (j = 0)
    li    s3, 0               # s3 = 0 (bắt đầu từ phần tử đầu tiên)

inner_loop: 
    # Tính giới hạn cho inner loop: j < (n - 1 - i)
    li    t1, 10              # t1 = 10 (số phần tử)
    sub   t1, t1, s2          # t1 = t1 - s2 (n - i)
    addi  t1, t1, -1          # t1 = t1 - 1 (n - 1 - i)
    bge   s3, t1, inner_done  # Nếu s3 >= t1, nhảy đến inner_done

    # Tính địa chỉ của A[j]: t3 = s0 + (s3*4)
    slli  t3, s3, 2           # t3 = s3 * 4 (offset của A[j])
    add   t3, s0, t3          # t3 = s0 + t3 (địa chỉ của A[j])
    lw    t4, 0(t3)           # t4 = A[j]

    # Tính địa chỉ của A[j+1]: t5 = s0 + ((s3 + 1)*4)
    addi  t5, s3, 1           # t5 = s3 + 1 (j + 1)
    slli  t5, t5, 2           # t5 = t5 * 4 (offset của A[j+1])
    add   t5, s0, t5          # t5 = s0 + t5 (địa chỉ của A[j+1])
    lw    t6, 0(t5)           # t6 = A[j+1]

    # So sánh và hoán đổi nếu cần:
    # Nếu A[j] <= A[j+1] thì không đổi, nếu A[j] > A[j+1] thì hoán đổi
    ble   t4, t6, no_swap     # Nếu t4 <= t6, nhảy đến no_swap
    sw    t6, 0(t3)           # A[j] = t6 (hoán đổi A[j] và A[j+1])
    sw    t4, 0(t5)           # A[j+1] = t4

no_swap: 
    addi  s3, s3, 1           # j++
    j     inner_loop           # Lặp lại inner_loop

inner_done: 
    # Sau mỗi lượt inner loop (1 pass), gọi procedure in mảng
    jal   ra, printArray      # Gọi hàm printArray để in mảng
    addi  s2, s2, 1           # i++
    j     outer_loop           # Lặp lại outer_loop

sort_done: 
    # In mảng cuối cùng đã được sắp xếp
    jal   ra, printArray      # Gọi hàm printArray để in mảng
    li    a7, 10             # Chuẩn bị để kết thúc chương trình
    ecall                     # Kết thúc chương trình

#--------------------------------------------------------- 
# Procedure printArray: 
# In ra mảng theo định dạng "Array: <A[0]> <A[1]> ... <A[9]>\n" 
#--------------------------------------------------------- 
printArray: 
    la    a0, prompt        # In chuỗi "Array: " 
    li    a7, 4             # Chuẩn bị để in chuỗi
    ecall                   # Gọi hệ thống để in chuỗi

    la    t0, A             # t0 = địa chỉ đầu mảng A
    li    t1, 10            # t1 = số phần tử cần in (10)

print_loop: 
    beq   t1, zero, print_done   # Nếu t1 == 0, nhảy đến print_done
    lw    t2, 0(t0)         # t2 = A[i]
    mv    a0, t2            # a0 = t2 (chuẩn bị để in số nguyên)
    li    a7, 1             # Chuẩn bị để in số nguyên
    ecall                   # Gọi hệ thống để in số nguyên

    la    a0, space         # In khoảng trắng giữa các số
    li    a7, 4             # Chuẩn bị để in chuỗi
    ecall                   # Gọi hệ thống để in chuỗi

    addi  t0, t0, 4         # Chuyển đến phần tử kế tiếp (t0 += 4)
    addi  t1, t1, -1        # Giảm số phần tử cần in (t1--)
    j     print_loop         # Lặp lại print_loop

print_done: 
    la    a0, newline       # Xuống dòng sau khi in xong
    li    a7, 4             # Chuẩn bị để in chuỗi
    ecall                   # Gọi hệ thống để in chuỗi
    jr    ra                # Trở về địa chỉ được lưu trong ra