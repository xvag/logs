# this program implements this c code:
#
# clear1(int array[], int size) {
# int i;
# for (i=0; i<size; i+= 1)
# 	array[i] = 0;
# }
#
# with array[4]={14,25,24,32}

.data
array: .word 14 25 24 32
size: .word 4

.text
.globl main
main:

la $a0, array
lw $a1, size

jal clear1

li $v0,10
syscall

clear1:
move $t0,$zero		# i = 0
loop1: 
sll $t1,$t0,2		# $t1 = i * 4
add $t2,$a0,$t1		# $t2 = &array[i]
sw $zero, 0($t2) 	# array[i] = 0
addi $t0,$t0,1		# i = i + 1
slt $t3,$t0,$a1 	# $t3 = 1 if (i<size) else $t3 = 0
bne $t3,$zero,loop1	# if ($t3 != 0) goto loop1
jr $ra				# return to main

