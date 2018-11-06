.data

.text

main:
# get the size of the list
li $v0, 5
syscall
move $s0, $v0               # size of list (e.g. 3)

# allocate heap space
li $t9, 4                   # byte size of int
li $v0, 9                   # create heap
mul $a0, $s0, $t9           # total bytes needed for the heap
syscall                     # base address of heap will be $v0
move $s1, $v0               # $s1 = base address of heap

# get first member of the list
li $v0, 5
syscall
sw $v0, ($s1)

# get second member of the list
li $v0, 5
syscall
add $s1, $s1, $t9
sw $v0, ($s1)

# get third member of the list
li $v0, 5
syscall
add $s1, $s1, $t9
sw $v0, ($s1)
#sw $v0, 8($s1)

# print last element
li $v0, 1
lw $a0, ($s1)
sub $s1, $s1, $t9
syscall

# print second last element
li $v0, 1
lw $a0, ($s1)
sub $s1, $s1, $t9
syscall

# print third last element
li $v0, 1
lw $a0, ($s1)
sub $s1, $s1, $t9
syscall

# exit
li $v0, 10
syscall