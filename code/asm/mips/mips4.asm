.data
msg1: .asciiz "Zero"
msg2: .asciiz "Non Zero"
msgpos: .asciiz "Positive"
msgneg: .asciiz "Negative"

.text
.globl main
main:

# reads an int and prints if
# it is zero or non-zero

li $v0,5
syscall
bne $v0,0,NONZERO
la $a0,msg1
j ZERO
NONZERO:
la $a0,msg2
ZERO:
li $v0,4
syscall

li $a0,'\n'
li $v0,11
syscall

# reads an int and prints if
# it is positive or negative

li $v0,5
syscall
slti $t0,$v0,0
beq $t0,1,NEG
la $a0,msgpos
j POS
NEG:
la $a0,msgneg
POS:
li $v0,4
syscall

li $a0,'\n'
li $v0,11
syscall

# prints the char * five times

li $t0,0
LOOP:
li $a0,'*'
li $v0,11
syscall
addi $t0,$t0,1
bne $t0,5,LOOP

li $a0,'\n'
li $v0,11
syscall

# reads a num and prints
# the char * num-times

li $v0,5
syscall
move $t0,$v0
li $t1,0
LOOP2:
slt $t2,$t1,$t0
beq $t2,$zero,EXIT
li $a0,'*'
li $v0,11
syscall
addi $t1,$t1,1
j LOOP2
EXIT:

li $a0,'\n'
li $v0,11
syscall

# prints five lines with each
# having the char * four times

li $t1,0
LOOP4:
li $t0,0
LOOP3:
li $a0,'*'
li $v0,11
syscall
addi $t0,$t0,1
bne $t0,4,LOOP3
li $a0,'\n'
li $v0,11
syscall
addi $t1,$t1,1
bne $t1,5,LOOP4

li $a0,'\n'
li $v0,11
syscall

# reads two nums (x,y) and prints
# x lines with each having the 
# char * y-times

li $v0,5
syscall
move $t2,$v0
li $v0,5
syscall
move $t3,$v0

li $t1,0
OUT:
slt $t8,$t1,$t2
beq $t8,$zero,EXIT1
li $t0,0
IN:
slt $t8,$t0,$t3
beq $t8,$zero,EXIT2
li $a0,'*'
li $v0,11
syscall
addi $t0,$t0,1
j IN
EXIT2:
li $a0,'\n'
li $v0,11
syscall
addi $t1,$t1,1
j OUT
EXIT1:

li $v0,10
syscall
