.data
newline: .asciiz "\n"
.text
#Use t0 as upper part and t1 as lower part
Test_Shift:
li $t0 0
li $t1 1
li $t2 0
Loop:
#Take out the 32th bit
srl $t3 $t1 31
andi $t3 $t3 1 #Make sure that we only take the last bit
#Shift left lower part
sll $t1 $t1 1
#Shift left the upper part
sll $t0 $t0 1
#Add the MSB of lower part to LSB part of upper part
or $t0 $t0 $t3
#Print out the number after every shift time
move $a0 $t0
li $v0 1
syscall
move $a0 $t1
li $v0 1
syscall
li $v0 4
la $a0 newline
syscall
addi $t2 $t2 1
blt $t2 62 Loop
#End of shift test
li $v0 10
syscall
