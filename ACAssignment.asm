.data
	#Necessary data goes here
.text
.globl main
	#Read input from .BIN file
read_input:

main:
##########################################################
	#Additional information:
		#t0 is used to count the loop time (when applying the multiplication algorithm)
		#in the multiplication function.
		
		#t2 is used to store the sign of the result.
		
		#Because the input is 32 bit but it is extended to 64 bit, the a1 is used as the multiplicand parameter,
		#then it is extended to 64 bit by connecting with a0 register.
		
		#The a2 register is used as the multiplier.
		
		#Because the final result is 64 bits, we use v0 as the MSB and v1 as the LSB
###########################################################
	#Read input then move the values into a1 and a2, the parameters for the function
	li $v0 5
	syscall
	move $a1 $v0			#a1 is multiplicand
	li $v0 5
	syscall
	move $a2 $v0			#a2 is multiplier
	###################################################
	#SET SOME INITIAL STATES BEFORE CALLING THE FUNCTION
	###################################################
	li $a0 0 			#As the multiplicand is 32 bit initially, we assume that the upper 32 bit is 0, no matter
					#what the sign of the multiplicand is.
					
	########################################################
	#Store the old value of s registers into stack (If used)
	#Or load inital value for some registers
	li $t2 0			#Set the initial value for sign indicator register
	
	
	########################################################
	#Call and jump to the function
	jal multiplication
	#######################################################
	#After returning back from the function, jump to exit to terminate the program
	j exit
##################################
#The main multiplication function
##################################
multiplication:
#######################################
#Check the sign of two numbers
#Description: Use t2 resgister as an sign indicator. If t2 equals to 1, it indicates that the sign is changed 
a1_sign_check:
	blt $a1 $zero a1_sign_change	#Check if multiplicand is less than zero
					#If true, branch to the tag to change its sign
	j a2_sign_check			#If false, check the sign of multiplier
a2_sign_check:
	blt $a2 $zero a2_sign_change
	j multiplication_cont
########################################
a1_sign_change:				
	subu $a1 $zero $a0 		#Assign a1 with 0 - a1 to change the sign
	xori $t2 1			#Use xori to change t2, indicating that the sign is changed. This is equal to NOT
	j a2_sign_check			#Go back to check the sign of multiplier
#The tag to check sign of a1
a2_sign_change:
	subu $a2 $zero $a1 		#Assign a2 with 0 - a2 to change the sign
	xori $t2 1			#Use xori to change t2, indicating that the sign is changed. This is equal to NOT
	j multiplication_cont		#Go back to check the a1's sign
########################################
#End of checking sign
########################################
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
	
