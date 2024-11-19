.data
filename: .asciiz "INT2.BIN"
buffer: .align 2 
	.space 8
.text
#Open File
li $v0 13
la $a0 filename
li $a1 0
li $a2 0
syscall
move $s0 $v0

#Read 8 bytes from file
li $v0 14
move $a0 $s0
la $a1 buffer
la $a2 8
syscall

#Close file
li $v0 16
move $a0 $s0 
syscall

#Read from buffer to register
la $a0 buffer
lw $t1 0($a0)
lw $t2 4($a0)
j exit

exit:
	li $v0 10
	syscall
#Read data from buffer to register
li $v0 4
la $a0 buffer
syscall
la $t2 buffer
string_to_int_loop:
lb $t3 0($t2)
beq $t3 32 save_num
beq $t3 0 end_loop
sub $t3 $t3 '0'
mul $t4 $t4 10
add $t4 $t4 $t3
addi $t2 $t2 1
j string_to_int_loop
save_num:
move $s0 $t4
li $t4 0
addi $t2 $t2 1
j string_to_int_loop
end_loop:
move $s1 $t4
li $t4 0

li $v0 1
move $a0 $s0
syscall
li $v0 1
move $a0 $s1
syscall

