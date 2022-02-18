# float numbers arithmetic
# calculates ax^2+bx+c

.data
str: .asciiz "Enter x: "
a: .float 1.0
b: .float 1.0
c: .float 1.0

.text

l.s $f3,a
l.s $f4,b
l.s $f5,c

li $v0,4
la $a0, str
syscall

li $v0,6
syscall

mul.s $f1,$f0,$f0
mul.s $f1,$f1,$f3

mul.s $f2,$f0,$f4

add.s $f1,$f1,$f2
add.s $f1,$f1,$f5

mov.s $f12,$f1
li $v0,2
syscall

li $v0, 10
syscall

