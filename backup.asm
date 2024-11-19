.text
#Read input from .BIN file

readinput:

main:
	#Additional information:
		#t2 is used to store the sign of the result
		#Because the final result is 64 bits, we use v0 as the MSB and v1 as the LSB
	#Read input then move the values into a0 and a1, the parameters for the function
	li $v0 5
	syscall
	move $a0 $v0			#a0 is multiplicand
	li $v0 5
	syscall
	move $a1 $v0			#a1 is multiplier
	#Call and jump to the function
	jal multiplication
	j exit
#The main multiplication function
multiplication:
	#Check the sign of two numbers
a0_sign_check:
	blt $a0 $zero negative_check_a0
	j a1_sign_check
a1_sign_check:
	blt $a1 $zero negative_check_a1
	j multiplication_cont
#The tag to check sign of a0
negative_check_a0:
	subu $a0 $zero $a0 		#Assign a0 with 0 - a0 to change the sign
	xori $t2 1			#Use xori to change t2, indicating that the sign is changed
	j a1_sign_check			#Go back to check the a1's sign
#The tag to check sign of a1
negative_check_a1:
	subu $a1 $zero $a1 		#Assign a0 with 0 - a0 to change the sign
	xori $t2 1			#Use xori to change t2, indicating that the sign is changed
	j multiplication_cont		#Go back to check the a1's sign
#Continue the mulplication
multiplication_cont:
	#After check sign, crreate a loop to implement multiplication algorithm
	li $t0 0 			#t0 is used to count loops
loop:
	addi $t0 $t0 1			#Increse loop count
	andi $t1 $a1 1			#t1 stores the rightmost bit in multiplier
	beq $t1 1 increase_product	#if t1 equals to 1, get to increase_product tag to add multiplicand to product
continue:		
	li $t8 2147483648		#store the highest bit in the old product
	#andi $t7 $t8 $t9		#in t7
	srl $a1 $a1 1			#shift left product
	sll $a0 $a0 1			#and shift right multiplier
	bne $t0 32 loop			#If not 32 repetitition, continue
	j multiplication_cont_return		#Else break the loop to return value
increase_product:
	add $t9 $zero $v1		#Store the old value of product before add
	addu $v1 $v1 $a0		#Add the value
	#blt $a1 $t9 lsb_overflow_handler#iIf there is overflow error, goes to the overflow handler to fix
	j continue
multiplication_cont_return:
	bne $t2 $zero add_return_sign
function_return:
	jr $ra
add_return_sign:
	subu $v1 $zero $v1
	j function_return
exit:
	li $v0 1
	move $a0 $v1
	syscall
	li $v0 10
	syscall
lsb_overflow_handler:
	
