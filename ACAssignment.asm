##########################################################
#DATA DEFINITION
##########################################################
.data
#Necessary data goes here
##########################################################
#Below is the buffer that is used to store the information from binary file INT2.BIN
binary_buffer:  .align 2	#Align the space to the word boundary (2^2 = 4 bytes)
				#So that the address of the file byte is
				#divisible by 4, allowing
				#load word from the space.
		.space 8	#The space is 8 bytes long,
				#in order to store enough space for
				#two 32-bit integers.

#Below are strings that are used for getting input from binary file
filename: .asciiz "INT2.BIN"	#Name of the file that will be read

#Below are strings that are used for printing information.

#Thse are strings that provide information about the values of multiplicand and multiplier from binary file
multiplicand_input_information: .asciiz "The multiplicand from binary file is: "
multiplier_input_information: .asciiz "The multiplier from binary file is: "

#These are only temporary: As we will not get input from keyboard but from binary file
multiplicand_input_notification: .asciiz "Type in the multiplicand: "	#Multiplicand input notification
multiplier_input_notification: .asciiz "Type in the multiplier: "	#Multiplier input notification

#New line character
new_line: .asciiz "\n"

#These strings are used to provide information when printing out the result
lower_part_result: .asciiz "The lower part of the result is: "
higher_part_result: .asciiz "The higher part of the result is: "
binary_result: .asciiz "Result in binary: "
hexa_result: .asciiz "Result in hexadecimal: "
###########################################################
######			###			###########
#START			THE 			PROGRAM  ##
######			###			###########
###########################################################

.text
.globl main
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
		
		#t5 is used as the carry bit when an overflow occurs in lower part
		
		#The result after returning from the function is in v0 and v1 (higher and lower part respectively).
		#However, for using syscall, we move it to s0 and s1 respectively to store the result
##########################################################
#Read input then move the values into a1 and a2,
#the parameters for the function
##########################################################
#Get input from binary file INT2.BIN
###############################
#Open file INT2.BIN
	li $v0 13	#Syscall 13 to open file.
	la $a0 filename	#a0 stores the name of the binary file
	li $a1 0	#Set the open file mode to: Read only
	li $a2 0	#Set the flag to: Normal
	syscall		#After syscall, the file descriptor is stored in v0 register
	move $s2 $v0	#Move the file descriptor from v0 to s2 (This is used to
			#close the file later
#End of open file INT2.BIN
################################
#Read 8 bytes from the file
	li $v0 14		#Syscall 14 to read from file	
	move $a0 $s2		#a0 stores the file descriptor
				#of the file we are going to read
	la $a1 binary_buffer	#a1 stores the space we store the information
				#that is read from file
	la $a2 8		#a2 stores the number of bytes we are
				#going to read
	syscall			#8 bytes are read and stored in binary_buffer
#End of read file to space
#################################
#Close binary file INT2.BIN
li $v0 16			#Syscall 16 to close the file
move $a0 $s2 			#a0 stores the file descriptor of closed file
syscall
#End of closing binary file INT2.BIN
#################################
#Assign the values from space into registers
	la $t3 binary_buffer 	#t3 stores the array the information is in
	lw $a1 0($t3)		#Store the first number (multiplicand also)
				#into the first parameter a1
	lw $a2 4($t3)		#Store the second number (multiplier also)
				#into the second parameter a2
#End of assigning value into registers
##################################
#Print out the values of multiplicand and multiplier
	#Print out the multiplicand information
	la $a0 multiplicand_input_information	#Load multiplicand information
	li $v0 4
	syscall
	move $a0 $a1		#a0 stores the printed integer
	li $v0 1		#Syscall 1 to print integer
	syscall
	
	#Begin a new line
	la $a0 new_line
	li $v0 4
	syscall
	
	#Print out the multiplier information
	la $a0 multiplier_input_information
	li $v0 4
	syscall
	
	move $a0 $a2
	li $v0 1
	syscall
	
	#Begin a new line
	la $a0 new_line
	li $v0 4
	syscall
#End of values printing
#################################
#End of binary file from INT2.BIN
##########################################################
	###################################################
	#SET SOME INITIAL STATES BEFORE CALLING THE FUNCTION
	###################################################
	li $a0 0 			#As the multiplicand is 32 bit initially, we assume 
					#that the upper 32 bit is 0, no matter
					#what the sign of the multiplicand is.
					#Also reset a0 after syscall
	li $s2 0		
	########################################################
	#Store the old value of s registers into stack (If used)
	#Or load inital value for some registers
	li $t2 0			#Set the initial value for sign indicator register
	li $v0 0			#Reset after syscall
	li $t3 0
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
#Before enter: check edge case: either multiplicand or multiplier equals to 0
	#Branch to the handler if multiplicand or 
	#multiplier equals to 0 
	beq $a1 0 zero_operand_handler
	beq $a2 0 zero_operand_handler
	
	#If not, continue to check the sign 
	#of 2 operands 
	j a1_sign_check	

##########################
#Handle the zero edge case
zero_operand_handler:
	#Load both v0 and v1 to zero
	li $v0 0
	li $v1 0
	
	#Immediately return and go 
	#out of the function
	j function_return
#End of zero edge case handler
##########################

#End of edge case check
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
	subu $a1 $zero $a1 		#Assign a1 with 0 - a1 to change the sign
	xori $t2 1			#Use xori to change t2, indicating that the sign is changed. This is equal to NOT
	j a2_sign_check			#Go back to check the sign of multiplier
#The tag to check sign of a1
a2_sign_change:
	subu $a2 $zero $a2		#Assign a2 with 0 - a2 to change the sign
	xori $t2 1			#Use xori to change t2, indicating that the sign is changed. This is equal to NOT
	j multiplication_cont		#Go back to check the a1's sign
########################################
#End of checking sign
#########################################
#Continue multiplication

multiplication_cont:

#########################################
#After check sign, crreate a loop to implement multiplication algorithm

	li $t0 0 			#Initialize t0 to start counting
	
########################################
#LOOP START
########################################
loop:
	addi $t0 $t0 1			#Increse loop count
	andi $t1 $a2 1			#Store the rightmost bit in multiplier in t1
	beq $t1 1 increase_product	#if t1 equals to 1, get to increase_product tag to add multiplicand to product

#########################################
#Continue the loop after branching from increase_product
continue:		
########################################
#Shift left the 64 bit multiplicand
	
	#Store the leftmost bit of lower part in t6
	srl $t6 $a1 31
	andi $t6 $t6 1 			#Make sure that we only take one bit
	
	#Shift left the lower part
	sll $a1 $a1 1
	
	#Shift left the higher part
	sll $a0 $a0 1
	
	#Add the old leftmost bit of lower part (currently in t6) into
	#the rightmost bit of higher part
	or $a0 $a0 $t6
	
	#Shift right the multiplier
	srl $a2 $a2 1
#End of bit shift
########################################
#Loop check

	bne $t0 32 loop				#If not 32nd repetitition, continue
	j multiplication_cont_return		#Else break the loop to return value
	
#End of loop check
########################################
#BEGIN: Increase the product by adding the product with the current multiplicand.
########################################
increase_product:
#Add the lower part of multiplicand ($a1) to the lower part of product ($v1) 
	addu $v1 $v1 $a1
	
#t9 register is used as the carry bit. When using addu, if an overflow occurs,
#the current value will be lower than either of the operands. Then we assign
#the carry bit with 1
	sltu $t9 $v1 $a1
	
#Add the carry bit to the higher part of the product first, then add the higher part
#of the multiplicand
	addu $v0 $v0 $t9
	addu $v0 $v0 $a0

#Jump back to the loop after adding
	j continue
	
#END OF PRODUCT ADDITION
########################################
#Return after loop end

multiplication_cont_return:

	#If the sign bit (t2) is equals to 1, add the sign back
	#to the result
	bne $t2 $zero add_return_sign
	
function_return:
	#Return the result in v0 and v1 and go out of the function
	jr $ra
	
#End of return
########################################
#Add the sign back after changing at the beginning
add_return_sign:

	#If 
	#subu $v1 $zero $v1
	# ??o d?u 64-bit
	not $v0, $v0         # Bù 1 ph?n cao
	not $v1, $v1         # Bù 1 ph?n th?p
	addiu $v1, $v1, 1    # C?ng 1 vào ph?n th?p
	sltu $t9, $v1, $zero # Ki?m tra carry (n?u $v1 = 0 sau khi c?ng)
	addu $v0, $v0, $t9   # C?ng carry vào ph?n cao
	#Jump back to the function to return
	j function_return

#End of return sign function
#######################################
#Final steps, including print out the lower part and higher part of the function.

#Also store the 64 bit result into s0 and s1 register (because the $v0 containing
#the high part is used for syscall.

#Finally, exit from the program. 
exit:
	#Move the 64 bit result into s0 and s1 registers.
	move $s0 $v0		#The higher part is stored in s0
	move $s1 $v1		#The lower part is stored in s1
	
	#Print out the lower part in decimal
	la $a0 lower_part_result
	li $v0 4
	syscall
	li $v0 1		#Set v0 as 1 for printing integers (signed)
	move $a0 $s1		#Move the lower part of result into a0
	syscall			#Print out
	la $a0 new_line		#Begin a new line
	li $v0 4		#Syscall 4 to print out a string
	syscall
	
	#Print out the higher part in decimal 
	la $a0 higher_part_result
	li $v0 4
	syscall
	li $v0 1		#Set v0 as 1 for printing integers (signed)
	move $a0 $s0		#Move the upper part of result into a0
	syscall			#Print out.
	la $a0 new_line		#Begin a new line
	li $v0 4		#Syscall 4 to print out a string
	syscall
	
	#Print out the result in binary form
	la $a0 binary_result	
	li $v0 4
	syscall
	li $v0 35		#Syscall 35 to print the result in binary
	move $a0 $s0		#move s0 to a0 to print out the higher part 
	syscall			
	move $a0 $s1		#Move s1 to a0 to print out the lower part
	syscall
	la $a0 new_line		#Begin a new line
	li $v0 4		#Syscall 4 to print out a string
	syscall
	
	#Print out the result in hexadecimal form
	la $a0 hexa_result
	li $v0 4
	syscall
	li $v0 34		#Syscall 34 to print out the result in hexedecimal
	move $a0 $s0		#Move s0 to a0 to print out the higher part
	syscall		
	move $a0 $s1		#Move s1 to a0 to print out the lower part
	syscall

	#Syscall 10 to terminate execution
	li $v0 10		#Set the v0 register to 10 to set up for exit syscall
	syscall			#Call the syscall to terminate execution

#End of exit
############################################################
####			##			############
#END			OF			PROGRAM  ###
####			##			############
############################################################

	
