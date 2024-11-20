#=========================================================================================
# Program: Multiplication Algorithm Implementation
# Description: This program implement the multiplication
#	algorithm between 2 signed 32 bit integers.
#	The input is read from a binary file called 
#	INT2.BIN.
#References: The algorithm is taken from figure 3.4 and 3.5
#	of textbook: Computer Organization and Design - 4th
#	edition, David A.Patterson & John L.Hennessy.
# Class: L10.
# Group: 10.
# Authors: Nguyen Vo Duc Son, Pham Duy Quy, Nguyen Lam.
# Date: 20/11/2024.
#=========================================================================================

#=========================================================================================
#
#
#DATA DEFINITION
#
#
#=========================================================================================
.data				#Necessary data goes here
#-----------------------------------------------------------------------------------------
#The buffer that is used to store the information from binary file INT2.BIN
binary_buffer:  .align 2	#Align the space to the word boundary (2^2 = 4 bytes)
				#So that the address of the file byte is
				#divisible by 4, allowing
				#load word from the space.
		.space 8	#The space is 8 bytes long,
				#in order to store enough space for
				#two 32-bit integers.
#The buffer that is used to store the information before writing to OUTPUT.TXT
output_buffer:	.align 2	#Align the space to the word boundary (2^2 = 4 bytes)
				#So that the address of the file byte is
				#divisible by 4, allowing
				#load word from the space.
		.space 8	#The space is 8 bytes long,
				#in order to store enough space for
				#two 32-bit integers.			
#String for getting input from binary file
filename: .asciiz "INT2.BIN"	#Name of the file that will be read

#String for printing output
output: .asciiz "OUTPUT.TXT"

#String for opening or reading file
file_error: .asciiz "Error when opening/reading file. Program exit..."
file_success: .asciiz "Write into file OUTPUT.TXT successfully. Program exit..."
#Strings that provide information about the values of multiplicand and multiplier from binary file
multiplicand_input_information: .asciiz "The multiplicand from binary file is: "
multiplier_input_information: .asciiz "The multiplier from binary file is: "

#New line character
new_line: .asciiz "\n"

#Strings that are used to provide information when printing out the result
lower_part_result: .asciiz "The lower part of the result is: "
higher_part_result: .asciiz "The higher part of the result is: "
binary_result: .asciiz "Result in binary: "
hexa_result: .asciiz "Result in hexadecimal: "
#==========================Registers======================================================
#$t0: Loop time
#$t2: Sign of result
#$a1: Multiplicand
#$a0: Upper part of multiplicand (Sign-Extended initially)
#$a2: Multiplier
#$v0: Upper part of the result after returning from the function
#$v1: Lower part of the result after returning from the function
#$t5: Carry bit, used to handle overflow happens in lower part addition
#$s0 and $s1: Two parts of the result. They are used because $v0 is used for syscall after
#	returning from the function
#=========================================================================================
#
#
#Main function
#
#
#=========================================================================================
.text				#The main code
.globl main			#The main function starts here
#-----------------------------------------------------------------------------------------
main:
#***********************Read input from binary file**************************************#
#--------------------------------------
#1. Get input from binary file INT2.BIN
#--------------------------------------
#Open file INT2.BIN
	li $v0 13		#Syscall 13 to open file.
	la $a0 filename		#a0 stores the name of the binary file
	li $a1 0		#Set the open file mode to: Read only
	li $a2 0		#Set the flag to: Normal
	syscall			#After syscall, the file descriptor is stored in v0 register
	move $s2 $v0		#Move the file descriptor from v0 to s2 (This is used to
				#close the file later)
#--------------------------------------
#2. Read 8 bytes from the file
#--------------------------------------
	li $v0 14		#Syscall 14 to read from file	
	move $a0 $s2		#a0 stores the file descriptor
				#of the file we are going to read
	la $a1 binary_buffer	#a1 stores the space we store the information
				#that is read from file
	la $a2 8		#a2 stores the number of bytes we are
				#going to read
	syscall			#8 bytes are read and stored in binary_buffer
#--------------------------------------
#3. Close binary file INT2.BIN
#--------------------------------------
li $v0 16			#Syscall 16 to close the file
move $a0 $s2 			#a0 stores the file descriptor of closed file
syscall
#------------------------------------------------------
#4. Assign the values from space to parameter registers
#------------------------------------------------------
	la $t3 binary_buffer 	#t3 stores the address of the array the information is in
	lw $a1 0($t3)		#Store the first word (multiplicand also)
				#into the first parameter a1
	lw $a2 4($t3)		#Store the second word (multiplier also)
				#into the second parameter a2
#------------------------------------------------------
#5. Print out values of multiplicand and multiplier
#------------------------------------------------------
	#Print out the multiplicand information
	la $a0 multiplicand_input_information	#Load multiplicand information string
	li $v0 4				#Syscall 4 to print string
	syscall
	move $a0 $a1		#a0 stores the multiplicand
	li $v0 1		#Syscall 1 to print integer
	syscall
	
	#Begin a new line
	la $a0 new_line
	li $v0 4
	syscall
	
	#Print out the multiplier information
	la $a0 multiplier_input_information	#Load multiplier information string
	li $v0 4				#Syscall 4 to print string
	syscall
	
	move $a0 $a2		#a0 stores the multiplier
	li $v0 1		#Syscall 1 to print integer
	syscall
	
	#Begin a new line
	la $a0 new_line
	li $v0 4
	syscall
#***********************End of reading input from binary file**************************************#
#***********************Set initial states*********************************************************#
	li $a0 0 			#We sign change any negative numbers into positive, so
					#a0 will always be 0 no matter what the sign of the
					#multiplicand is.
					#This is also used to reset a0 to 0 after using it for
					#Syscall
					
	li $s2 0			#Reset $s2 to 0 after using it for storing file descriptor
	
	li $v0 0			#Reset after syscall

	li $t2 0			#Set the initial value for sign indicator register
	
	li $t3 0			#Reset $t3 to 0 after using it for storing space addrress
#***********************End of setting initial states*********************************************#
#************************************Other********************************************************#
	#Call and jump to the function
	jal multiplication
	
	#After returning back from the function, jump to exit to terminate the program
	j _exit
#=========================================================================================
#The main multiplication function
#=========================================================================================
multiplication:
#************************************Edge case check*********************************************#
#Before enter: check edge case: either multiplicand or multiplier equals to 0
	#Branch to the handler if multiplicand or 
	#multiplier equals to 0 
	beq $a1 0 _zero_operand_handler
	beq $a2 0 _zero_operand_handler
	
	#If not, continue to check the sign 
	#of 2 operands 
	j _multiplicand_sign_check

#Edge case handler
_zero_operand_handler:
	#Load both v0 and v1 to zero
	li $v0 0
	li $v1 0
	
	#Immediately return and go 
	#out of the function
	j _return
#End of zero edge case handler

#*******************************End of edge case check******************************************#

#------------------------------------------------------------------------------------------------
#1. Check the sign of two numbers
#Description: Use t2 resgister as an sign indicator. If t2 equals to 1, it indicates that the 
#sign is changed
#------------------------------------------------------------------------------------------------
_multiplicand_sign_check:
	blt $a1 $zero _multiplicand_sign_change		#Check if multiplicand is less than zero.
							#If true, branch to the tag to change 
							#its sign.
	j _multiplier_sign_check			#If false, check the sign of multiplier.
	
_multiplier_sign_check:					#Check if multiplicand is less than zero
	blt $a2 $zero _multiplier_sign_change		#If true, branch to the tag to change .
	j _multiplication_continue			#If false, continue the function.

_multiplicand_sign_change:				
	subu $a1 $zero $a1 				#Assign a1 with 0 - a1 to change the sign
	xori $t2 1					#Use xori to change t2, indicating that the
							#sign is changed. This is equal to NOT.
	j _multiplier_sign_check			#Go back to check the sign of multiplier

_multiplier_sign_change:
	subu $a2 $zero $a2				#Assign a2 with 0 - a2 to change the sign.
	xori $t2 1					#Use xori to change t2, indicating that the 
							#sign is changed. This is equal to NOT.
	j _multiplication_continue			#Go back to check the a1's sign
	
#------------------------------------------------------------------------------------------------
#2. Continue the multiplication after checking sign
#------------------------------------------------------------------------------------------------
_multiplication_continue:
#Create a loop to implement multiplication algorithm
	li $t0 0 			#Initialize t0 to start counting

#=========================================================================================
#Loop to calculate the product
#=========================================================================================
_loop:
	addi $t0 $t0 1			#Increse loop count
	andi $t1 $a2 1			#Store the rightmost bit in multiplier in t1
	beq $t1 1 increase_product	#if t1 equals to 1, get to increase_product tag to add multiplicand to product

#-------------------------------------------------------
#Continue the loop after branching from increase_product
#-------------------------------------------------------
continue:		
#-------------------------------------------------------
#Bit shift for multiplicand and multiplier

	srl $t6 $a1 31			#Store the leftmost bit of lower part in t6
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
	
#-------------------------------------------------------
#Loop condition check

	bne $t0 32 _loop		#If not 32nd repetitition, continue
	j _check_return_sign		#Else break the loop to return value
	
#--------------------------------------------------------------------------------
#Increase the product by adding the product with the current multiplicand.
#--------------------------------------------------------------------------------
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
#=========================================================================================
#End of loop
#=========================================================================================

	
#-------------------------------------------------------
#Check the sign bit to determine the sign of the product
_check_return_sign:

	#If the sign bit (t2) is equals to 1, add the sign back
	#to the result before returning
	bne $t2 $zero add_return_sign

#-------------------------------------------------------
#Return from the function
_return:

	#Return the result in v0 and v1 and go out of the function
	jr $ra
	
#-------------------------------------------------
#Add the sign back after changing at the beginning
add_return_sign:

	not $v0, $v0         # 1s complement of upper part
	not $v1, $v1         # 1s complement of lower part
	addiu $v1, $v1, 1    # add 1 to change lower part to 2s complement
	sltu $t9, $v1, $zero # Overflow check using $jt9
	addu $v0, $v0, $t9   # Add carry into upper part
	
	#Jump back to the function to return
	j _return

#================================================================================
#Final steps.
#Description: Print out the lower part and higher part of the function.
#Also store the 64 bit result into s0 and s1 register (because the $v0 containing
#the higher part is used for syscall.
#Then, store the result in a txt file.
#Finally, exit from the program. 
#================================================================================
_exit:
	#Move the 64 bit result into s0 and s1 registers.
	move $s0 $v0		#The higher part is stored in s0
	move $s1 $v1		#The lower part is stored in s1
	
	#Print out the lower part in decimal
	la $a0 lower_part_result	#Load string address into a0
	li $v0 4		#Syscall 4 to print string
	syscall
	li $v0 1		#Set v0 as 1 for printing integers (signed)
	move $a0 $s1		#Move the lower part of result into a0
	syscall			#Print out
	la $a0 new_line		#Begin a new line
	li $v0 4		#Syscall 4 to print out a string
	syscall
	
	#Print out the higher part in decimal 
	la $a0 higher_part_result	#Load string address into a0
	li $v0 4		#Syscall 4 to print string
	syscall
	li $v0 1		#Set v0 as 1 for printing integers (signed)
	move $a0 $s0		#Move the upper part of result into a0
	syscall			#Print out.
	la $a0 new_line		#Begin a new line
	li $v0 4		#Syscall 4 to print out a string
	syscall
	
	#Print out the result in binary form
	la $a0 binary_result	#Load string address into a0
	li $v0 4		#Syscall 4 to print string
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
	la $a0 hexa_result	#Load string address into a0
	li $v0 4		#Syscall 4 to print out a string
	syscall
	li $v0 34		#Syscall 34 to print out the result in hexedecimal
	move $a0 $s0		#Move s0 to a0 to print out the higher part
	syscall		
	move $a0 $s1		#Move s1 to a0 to print out the lower part
	syscall
	
#=====================================================================================
#Store result in text file
#=====================================================================================
	#Open or create file
	li $v0 13		#Syscall 13 to open/ create file
	la $a0 output		#Load the name of the output file into $a0
	li $a1 1		#$a1 is set to 1 for writing mode
	syscall 
	move $s2 $v0		#Move the file description from $v0 to $s2
	
	#Check file status
	bltz $v0 _file_error_handler	#If the value of $v0 is less than 0, it means that
					#an error happens in opening or reading file.
					#Branch to the file error handler
	
	#Enter the write file function
	move $a0 $s0		#Move the higher part of result into $a0
	move $a1 $s1		#Move the lower part of result into $a1
	jal write_file		#Enter the write_file function
	
	#Write from buffer to file
	sb $zero 0($t1)		#Add a null-terminator symbol into the end of buffer
	li $v0 15		#Syscall 15 to write into file
	move $a0 $s2		#Move the file descriptor into $a0
	la $a1 output_buffer		#Move the address of buffer that we want to write from
				#into $a1
	li $a2 17		#Set the number of bytes that we want to write to 17
				#(16 bytes of symbols, 1 byte of null-terminator symbol)
	syscall
	
	#Close the file
	li $v0 16		#Syscall 16 to close file
	move $a0 $s2		#Move the file descriptor to $a0
	syscall			#Close the file with description in $a0
	
	#Begin a new line
	la $a0 new_line
	li $v0 4
	syscall
	
	#Print out file write sucessfully
	la $a0 file_success
	li $v0 4
	syscall
	j _program_termination	#Terminate the program after closing the file
		
#*******************Handle the error in opening or reading files*********************#
_file_error_handler:
	la $a0 file_error
	li $v0 4
	syscall
	j _program_termination
#*********************write_file function here***************************************#
#Additional information: We need to convert the information in both registers into
#ASCII code before writing into the file. This function is is used to convert the result
#into ASCII code, and then store it in the output buffer to be ready for writing.
write_file:
	#Initialize before going into the loop
	li $t9 0		#$t9 is used as the loop counter
	la $t1 output_buffer	#$t1 stores the address of the buffer contains the value.
	
#Loop starts here
_write_loop:
	#Take out the first symbol
	addi $t9 $t9 1		#Increment the loop counter
	srl $t2 $a0 28		#Take 4 highest bits
	sll $a0 $a0 4		#Shift left 4 bits to remove the 4 highest bit
	andi $t2 $t2 0xF	#and with 1111 to make sure we only take 4 bits
	
	#Change the symbol into ASCII
	blt $t2 10 _digit_transform	#If the current value of 4 bits is less than 10,
					#convert it using _digit_transform
	j _char_transform		#Else, convert it using _char_transform

#Used to store the current symbol into the buffer
_store_char:
	sb $t2 0($t1)		#Store one symbol in the address in $t1
	addi $t1 $t1 1		#Incerase $t1 to increase the location in the buffer
	beq $t9 8 _swap		#If the number of loops equals to 8, it means that 
				#the upper part is all inserted in the buffer. Then
				#we go to _swap thread to start store the lower part.
	blt $t9 16 _write_loop	#If the number of loops is less than 8, continue the loop
	jr $ra			#Else, return back from the function
	
#Handle the less than 10 case
_digit_transform:
	addi $t2 $t2 48		#Turn into number in ASCII
	j _store_char		#Go back to store the character
	
#Handle the equal or more than 10 case
_char_transform:
	addi $t2 $t2 87
	j _store_char

#Move the value of $a1 into $a0 to continue
_swap:
	move $a0 $a1
	j _write_loop
#=====================================================================================
#Terminate the program
#=====================================================================================
_program_termination:
	#Syscall 10 to terminate execution
	li $v0 10		#Set the v0 register to 10 to set up for exit syscall
	syscall			#Call the syscall to terminate execution
#=====================================================================================
#
#
#END OF PROGRAM
#
#
#=====================================================================================

	
