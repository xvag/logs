#a
# reads an int and prints if
# it is even or odd

#b
# reads an int and prints if
# it is multiple by 4

#c
# reads an int and prints if
# it is positive or negative

#d
# reads an int (0-15) and prints
# its binary value

#e
# reads an int (1-255) and prints
# its hex value. the program uses
# the table "0123456789abcdef"

.data
evenmsg: .asciiz "The number is EVEN"
oddmsg: .asciiz "The number is ODD"
mulmsg: .asciiz "The number is multiple of 4"
nmulmsg: .asciiz "The number is NOT multiple of 4"
negmsg: .asciiz "The number is NEGATIVE"
posmsg: .asciiz "The number is POSITIVE"
table: .asciiz "0123456789abcdef"
promt: .asciiz "Give a number (1-255): "

.text
.globl main
main:

li $v0,5			#a
syscall
andi $t0,$v0,1
beq $t0,0,EVEN
la $a0,oddmsg
j PRINT
EVEN:
la $a0,evenmsg
PRINT:
li $v0,4
syscall

li $a0,'\n'
li $v0,11
syscall

li $v0,5			#b
syscall
andi $t0,$v0,3
beq $t0,0,MUL4
la $a0,nmulmsg
j PRINT2
MUL4:
la $a0,mulmsg
PRINT2:
li $v0,4
syscall

li $a0,'\n'
li $v0,11
syscall

li $v0,5			#c
syscall
srl $t0,$v0,31
andi $t1,$t0,1
beq $t1,0,POS
la $a0,negmsg
j PRINT3
POS:
la $a0,posmsg
PRINT3:
li $v0,4
syscall

li $a0,'\n'
li $v0,11
syscall

li $v0,5			#d
syscall
add $t0,$v0,0
li $t8,8
li $t1,4
LOOP:
subi $t1,$t1,1
and $t2,$t0,$t8
srlv  $a0,$t2,$t1
li $v0,1
syscall
srl $t8,$t8,1
beq $t1,0,EXIT
j LOOP
EXIT:

li $a0,'\n'
li $v0,11
syscall

la $a0,promt			#e
li $v0,4
syscall
li $v0,5
syscall
add $t0,$v0,0
li $t1,240
la $s0,table

and $t2,$t0,$t1
srl $t2,$t2,4
add $s1,$s0,$t2
lb $a0,0($s1)
li $v0,11
syscall

srl $t1,$t1,4
and $t2,$t0,$t1
add $s1,$s0,$t2
lb $a0,0($s1)
li $v0,11
syscall

li $v0, 10
syscall
