.data
msg1: .asciiz "Hello\n"
msg2: .asciiz "TEI\n"
myname: .space 20

.text
.globl main
main:

# prints chars a and d

li $a0,'a'
li $v0,11
syscall
li $a0,'\n'
li $v0,11
syscall
li $a0,'d'
li $v0,11
syscall
li $a0,'\n'
li $v0,11
syscall

# prints msg1, msg2

la $a0, msg1
li $v0,4
syscall
la $a0, msg2
li $v0,4
syscall

li $a0,5
li $v0,1
syscall

li $a0,'\n'
li $v0,11
syscall

# prints number 5

li $v0,5
syscall
move $a0,$v0
li $v0,1
syscall

li $a0,'\n'
li $v0,11
syscall

# reads and prints a string (myname)
li $v0,8
li $a1,20
la $a0,myname
syscall
li $v0,4
syscall

li $v0, 10
syscall
