.text
#Addition test
#t0 and t1 are 
li $t0 0x00000000
li $t1 0xFFFFFFFE
#t2 and t3 are sum
li $t2 0
li $t3 0x00000011 
addu $t3 $t1 $t3
#Use t5 as the carry bit
sltu $t5 $t3 $t1
addu $t2 $t2 $t5
addu $t2 $t0 $t2
move $a0 $t3
li $v0 36
syscall
li $v0 10
syscall
