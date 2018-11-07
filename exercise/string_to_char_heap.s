.data
str: .asciiz "abc"
newline: .asciiz "\n"
len: .word 4

.text

main:
la $s0, str
lw $s1, len

# create new heap
li $v0, 9
move $a0, $s1
syscall
move $s2, $v0           # $s2 = base of heap

jal ToHeap

move $a0, $s2
lw $a1, len
jal Print_heap

# exit
li $v0, 10
syscall

### first in last out (stack) ###
ToHeap:
# check whether all characters are in the heap
lb $t0, 0($s0)
beqz $t0, Finish_ra
# store $ra to stack
subi $sp, $sp, 4
sw $ra, ($sp)
# store character to heap
sb $t0, ($s2)           # store byte
addi $s0, $s0, 1        # increment str
addi $s2, $s2, 1        # increment heap
j ToHeap

### restore the state of $ra
Finish_ra:
lw $ra, ($sp)
addi $sp, $sp, 4
jr $ra

### put heap address to $a0, size to $a1
Print_heap:
move $t0, $a0           # heap address (top)
move $t1, $a1           # size of heap
beqz $t1, Finish_ra     # break if $t1 == 0
# store the state of $ra
subi $sp, $sp, 4
sw $ra, ($sp)
# print the char
li $v0, 11              # print char
lb $a0, 0($t0)          # the first char
syscall
# decrement the pointer and size of heap
subi $a0, $t0, 1
subi $a1, $t1, 1
# recurse
j Print_heap




Print_newline:
# store the states of $v0 and $a0
subi $sp, $sp, 8
sw $v0, 0($sp)
sw $a0, 4($sp)
# print newline
li $v0, 4
la $a0, newline
syscall
# restore the states of $v0 and $a0
lw $v0, 0($sp)
lw $a0, 4($sp)
addi $sp, $sp, 8
# return
jr $ra