# This program illustrates how to call a function 
# and use the stack to pass the arguments.

# To call a function use the jal call.
# Here the main program calls the function "first".

# To pass arguments (in this case some integers) use the 
# $a0-$a3 registers and if they are not enough use the stack.

# To return results from a function use the $v0 and $v1 
# registers and if they are not enough use the stack.

# To use the stack, bind as many positions as you need by
# moving the stack pointer ($sp) 4 bytes (which is the
# space needed for a word to be stored) per position. 
# When you are done, restore the stored values and the
# value of the stack pointer.

# This program calls the function "first" which implements:
#	int first(int a, int b, int c, int d, int e, int f) {
#		int x,y,z;
#		x = (a+b)-(c+d);
#		y = e-f;
#		z = x+y;
#		return z;
#	}

# a=$a3=6, b=$a2=5, c=$a1=4, d=$a0=3, e=$t1=2, f=$t0=1
# x=$s0, y=$s1, z=$ra

.data
str: .asciiz " is the result"

.text
.globl main
main:

li $v0,4		# prepare to print str
la $a0,str

addi $sp,$sp,-8		# bind 2 positions and store values of
sw $a0,4($sp)		# $v0 and $a0, in order to use them later.
sw $v0,0($sp)

li $t0,1		# initialize a,b,c,d,e,f
li $t1,2		# e($t0) and f($t1) will be passed
li $a0,3		# to the function through the stack
li $a1,4
li $a2,5
li $a3,6

addi $sp,$sp,-8		# bind 2 more positions and store
sw $t1,4($sp)		# e and f.
sw $t0,0($sp)

jal first		# call function "first"

add $a0,$v0,$zero	# move result to $a0 for printing
li $v0,1
syscall			# print the result

lw $v0,0($sp)		# restore previous values of $v0 and
lw $a0,4($sp)		# $a0 stored in the stack
addi $sp,$sp,8		# restore stack pointer
syscall			# print str

li $v0,10		#terminate
syscall


# function "first" starts here

first:
lw $t0,0($sp)		# restore e and f
lw $t1,4($sp)
addi $sp,$sp,8		# restore stack pointer

addi $sp,$sp,-12	# bind 3 positions and store the values
sw $s0,8($sp)		# of the registers that this function will 
sw $s1,4($sp)		# use, in order to protect them from 
sw $ra,0($sp)		# altering useful info.

add $a3,$a3,$a2		# do the math
add $a1,$a1,$a0
sub $s0,$a3,$a1
sub $s1,$t1,$t0
add $ra,$s0,$s1

add $v0,$ra,$zero	# move result to $v0

lw $ra,0($sp)		# restore the previous values of the
lw $s1,4($sp)		# registers used.
lw $s0,8($sp)
addi $sp,$sp,12		# restore stack pointer

jr $ra			# go back to main program
