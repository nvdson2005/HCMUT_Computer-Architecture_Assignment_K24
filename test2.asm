.data
filename: .asciiz "output_hex.txt"  # Tên file
buffer:   .space 32                # B? ??m ?? l?u chu?i th?p l?c phân

.text
main:
    # 1. Gán giá tr? th?p l?c phân vào thanh ghi $t0
    li $t0, 0x1234ABCD            # Giá tr? th?p l?c phân c?n l?u vào file

    # 2. M? ho?c t?o file
    li $v0, 13                    # Syscall 13: open
    la $a0, filename              # ??a ch? tên file
    li $a1, 1                     # Ch? ?? ghi (write)
    #li $a2, 0o644                 # Quy?n truy c?p (rw-r--r--)
    syscall
    move $s0, $v0                 # L?u file descriptor vào $s0

    # 3. Chuy?n giá tr? t? $t0 sang chu?i th?p l?c phân
    la $a0, buffer                # ??a ch? b? ??m
    move $a1, $t0                 # Giá tr? trong $t0
    jal int_to_hex                # G?i hàm chuy?n ??i s? sang chu?i th?p l?c phân

    # 4. Ghi chu?i th?p l?c phân vào file
    li $v0, 15                    # Syscall 15: write
    move $a0, $s0                 # File descriptor
    la $a1, buffer                # ??a ch? buffer ch?a chu?i
    li $a2, 10                    # S? byte t?i ?a ?? ghi (gi? ??nh buffer ?? l?n)
    syscall

    # 5. ?óng file
    li $v0, 16                    # Syscall 16: close
    move $a0, $s0                 # File descriptor
    syscall

    # 6. Thoát ch??ng trình
    li $v0, 10                    # Syscall 10: exit
    syscall

# Hàm: int_to_hex
# Chuy?n s? nguyên trong $a1 thành chu?i th?p l?c phân l?u trong $a0
int_to_hex:
    li $t1, 8                     # S? nibble (32-bit = 8 nibble)
    la $t2, buffer                # ?i?m b?t ??u c?a chu?i

convert_loop:
    sll $a1, $a1, 28              # L?y nibble cao nh?t (4 bit ??u tiên)
    srl $a1, $a1, 28              # L?y l?i 4 bit ??u tiên sau khi d?ch
    andi $t3, $a1, 0xF            # L?y giá tr? c?a nibble (0-15)
    
    # Chuy?n nibble thành ký t? ASCII
    blt $t3, 10, digit            # N?u nh? h?n 10: '0'-'9'
    addi $t3, $t3, 55             # Thêm 55 ?? thành 'A'-'F' (A = 65, 10 + 55)
    j store_char

digit:
    addi $t3, $t3, 48             # Thêm 48 ?? thành '0'-'9'

store_char:
    sb $t3, 0($t2)                # L?u ký t? vào buffer
    addi $t2, $t2, 1              # Ti?n con tr? buffer

    # Chu?n b? cho nibble ti?p theo
    srl $a1, $a1, 4               # D?ch ph?i 4 bit ?? l?y nibble ti?p theo
    subi $t1, $t1, 1              # Gi?m s? nibble còn l?i
    bgtz $t1, convert_loop        # Ti?p t?c n?u còn nibble

    # Thêm ký t? null k?t thúc chu?i
    sb $zero, 0($t2)
    jr $ra                        # Quay l?i
