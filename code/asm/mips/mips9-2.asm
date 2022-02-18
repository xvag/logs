# this program implements this c code:
#
# clear2(int *array, int size) {
# int *p;
# for (p = &array[0]; p < &array[size];p = p + 1)
# 	*p = 0;
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

jal clear2

li $v0,10
syscall

clear2:
move $t0,$a0		# p = &array[0]
sll $t1,$a1,2   		# $t1 = size * 4
add $t2,$a0,$t1 	# $t2 = array[size]
loop2:
sw $zero,0($t0) 		# *p = 0
addi $t0,$t0,4		# p = p + 4
slt $t3,$t0,$t2		# $t3 = 1 if (p<&array[size]) else $t3 = 0
bne $t3,$zero,loop2	# if ($t3 != 0) goto loop2
jr $ra
