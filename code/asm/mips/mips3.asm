.data

hellostr: .asciiz "hello"
inputstr: .space 100
x: .word 0
a: .word 20
b: .word 30
c: .word 15

.text
.globl main
main:

# prints first and second char from
# the string hellostr

la $t0,hellostr
lb $a0,0($t0)
li $v0,11
syscall
li $a0,'\n'
li $v0,11
syscall
lb $a0,1($t0)
li $v0,11
syscall
li $a0,'\n'
li $v0,11
syscall

# reads a num and prints the num-th
# char from string hellostr

li $v0,5
syscall
add $t1,$t0,$v0
lb $a0,0($t1)
li $v0,11
syscall
li $a0,'\n'
li $v0,11
syscall

# reads a strings and prints its
# second char

li $v0,8
li $a1,100
la $a0,inputstr
syscall
la $t0,inputstr
lb $a0,1($t0)
li $v0,11
syscall

# implements:
# int x, a=20, b=30, c=15;
# x=(a+b)-(c+10);

lw $t1,a
lw $t2,b
add $t3,$t2,$t1
lw $t1,c
add $t2,$t1,10
sub $t1,$t3,$t2
sw $t3,x

li $v0,10
syscall
