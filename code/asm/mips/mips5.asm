#a
# reads a string (max 15 chars)
# and prints the number of chars read

#b
# reads a string (max 15 chars)
# and prints it backwards

#c
# implements:
# main() {
#	int i, size=10, sum;
#	int arr[10]={1,15,0,-3,99,48,-17,-9,20,15};
#	sum-0;
#	for(i=0; i<=size; i++) {
#		sum += arr[i];
#	}
#	return 0;
# }

#d
# stores the value 0xabcd in 4 memory positions
# (first, second, third, fourth)
# using a loop

#e
# reads nums with the "read char" code,
# stores them in an array and
# prints the final num in num format.


.data
string1: .space 16
array: .word  1,15,0,-3,99,48,-17,-9,20,15
size: .byte 10
first: .word 0x0000
second: .word 0x0000
third: .word 0x0000
fourth: .word 0x0000
numbers: .byte

.text
.globl main
main:

li $v0,8		#a
li $a1,16
la $a0,string1
syscall

li $t0,0
LOOP:
lb $t1,0($a0)
beq $t1,$zero,EXIT
add $a0,$a0,1
add $t0,$t0,1
j LOOP
EXIT:
sub $t0,$t0,1
li $v0,1
move $a0,$t0
syscall

li $a0,'\n'
li $v0,11
syscall

li $v0,8		#b
li $a1,16
la $a0,string1
syscall

li $t0,0
LOOP2:
lb $t1,0($a0)
beq $t1,$zero,EXIT2
add $a0,$a0,1
add $t0,$t0,1
j LOOP2
EXIT2:

sub $a0,$a0,1
la $s0,0($a0)
sub $t0,$t0,1
LOOP3:
blt $t0,$zero,EXIT3
sub $t0,$t0,1
lb $a0,0($s0)
li $v0,11
syscall
sub $s0,$s0,1
j LOOP3
EXIT3:

la $s0,array		#c
li $t0,0
li $t1,0
lb $t3,size
LOOP4:
lw $t2,0($s0)
add $t1,$t1,$t2
addi $s0,$s0,4
addi $t0,$t0,1
bne $t3,$t0,LOOP4

li $t0,0xabcd		#d
li $t1,0
la $s0,first
LOOP5:
sw $t0,0($s0)
addi $s0,$s0,4
addi $t1,$t1,1
bne $t1,4 LOOP5

li $a0,'\n'
li $v0,11
syscall

la $s0,numbers		#e
li $t0,0
LOOP6:
li $v0,12
syscall
beq $v0,'\n',EXIT6
addi $a0,$v0,0
sb $a0,0($s0)
addi $s0,$s0,1
addi $t0,$t0,1
j LOOP6
EXIT6:
li $v0,4
add $a1,$t0,0
la $a0,numbers
syscall

li $v0,10
syscall
