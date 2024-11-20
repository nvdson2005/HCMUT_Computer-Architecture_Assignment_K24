.data
output: .asciiz "OUTPUT_HEX.TXT"
buffer: .align 2 
	.space 17
.text
	li $t0 0x1234bbcd
	li $t8 0x5678ffad
	li $v0 13		#Syscall 13 to open/ create file
	la $a0 output		#Load the name of the output file into $a0
	li $a1 1		#$a1 is set to 1 for writing mode
	syscall
	move $s0 $v0
	
	beqz $v0 _write_file
	blt $zero $v0 _write_file	
	j _open_file_error_handler

_write_file:
	li $t9 0	#Counter
	la $t1 buffer
loop:
	addi $t9 $t9 1
	srl $t2 $t0 28		#Take 4 highest bits
	sll $t0 $t0 4		#Shift left 4 bits to remove the 4 highest bit
	andi $t2 $t2 0xF	#and with 1111 to make sure we only take 4 bits
	
	#Change the bit into ASCII
	blt $t2 10 _digit_transform
	j _char_transform

_digit_transform:
	addi $t2 $t2 48		#Turn into number in ASCII
	j _store_char		#Go back to store the character

_char_transform:
	addi $t2 $t2 87
	j _store_char

_store_char:
	sb $t2 0($t1)
	addi $t1 $t1 1
	move $a0 $t2
	li $v0 11
	syscall
	beq $t9 8 _swap
	blt $t9 16 loop
_write_to_file:
	sb $zero 0($t1)
	li $v0 15
	move $a0 $s0
	la $a1 buffer
	li $a2 16
	syscall
#Close file
	li $v0 16
	move $a0 $s0
	syscall
	li $v0 10
	syscall
#_add_null_terminaltor:
	#sb $zero 0($t2)
_print_in_buffer:
	la $a0 buffer
	li $v0 4
	syscall
_open_file_error_handler:
	li $v0 10
	syscall
_swap:
	move $t0 $t8
	j loop