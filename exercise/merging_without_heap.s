# Implement merging which merges two strings and
# sort them. Result is put in a heap

.data
str:        .asciiz "246"
            .asciiz "135"
newline:    .asciiz "\n"
len:        .word   4
size:       .word   2

.text

main:
li $t9, 4               # $t9 = constant 4
la $s0, str             # $s0 = str
lw $s1, len             # $s1 = len
lw $s2, size            # $s2 = size of list

li $v0, 9
mul $a0, $s2, $t9       # $a0 = size * 4
syscall
move $s3, $v0           # $s3 = base address of string array

move $t0, $s2           # $t0 = size of list [i]
move $t1, $s3           # $t1 = pointer to the top of array (heap) [j]
la $t2, str             # $t2 = address of array

READ_DATA:
sw $t2, ($t1)           # base address of array = $t2 (first string)
addi $t1, $t1, 4        # increment pointer to array (heap)
add $t2, $t2, $s1       # increment pointer to str
sw $t2, ($t1)

lw $t6, ($t1)           # $t6 = str1
addi $t1, $t1, -4
lw $t7, ($t1)           # $t7 = str2

li $v0, 9
mul $s3, $s1, $s2       # $s3 = len(str) * size(list) = 8
move $a0, $s3           # $a0 = len(str) * size(list) = 8
syscall
move $s4, $v0           # $t3 = result heap

jal MERGING
subi $s4, $s4, 1        # point to the top element in heap
move $a0, $s4           # $a0 = top of result heap
subi $a1, $s3, 2        # $a1 = char to be printed (6)
jal PRINT_HEAP
j EXIT


MERGING:
    lb $t0, ($t6)           # n
    lb $t1, ($t7)           # |> chech if one of the first char
    beqz $t0, MERGE_STR2    # |> is \0, branch if yes
    beqz $t1, MERGE_STR1    # u
    
    addi $sp, $sp, -4       # store $ra
    sw $ra, ($sp)
    
    lb $t0, ($t6)           # $t0 = str1[0]
    lb $t1, ($t7)           # $t1 = str2[0]
    ## To print the result in descending order
    #ble $t0, $t1, CHOOSE_1  # jump CHOOSE_1 if $t0 <= $t1
    ## To print the result in ascending order
    ble $t0, $t1, CHOOSE_2  # jump CHOOSE_2 if $t0 <= $t1
# CHOOSE_2:
    sb $t1, ($s4)           # store byte to $s4 (result heap)
    addi $s4, $s4, 1        # increment result heap address
    addi $t7, $t7, 1        # increment str2 address
    j MERGING
CHOOSE_1:
    sb $t0, ($s4)           # store byte to $s4
    addi $s4, $s4, 1        # increment result heap address
    addi $t6, $t6, 1        # increment str2 address
    j MERGING   

MERGE_STR1:
lb $t0, ($t6)               # $t0 = load byte from $t6 (str1)
beqz $t0, FINISH_RA         # return if $t0 = 0 (\0)
addi $sp, $sp, -4           # store $ra
sw $ra, ($sp)
sb $t0, ($s4)               # store $t0 to $s4 (result heap)
addi $s4, $s4, 1            # increment result heap address
addi $t6, $t6, 1            # increment str1 address
j MERGE_STR1

MERGE_STR2:
lb $t0, ($t7)               # $t0 = load byte from $t7 (str2)
beqz $t0, FINISH_RA         # return if $t0 = 0 (\0)
addi $sp, $sp, -4           # store $ra
sw $ra, ($sp)
sb $t0, ($s4)               # store $t0 to $s4 (result heap)
addi $s4, $s4, 1            # increment result heap address
addi $t7, $t7, 1            # increment str2 address
j MERGE_STR2

### @param $a0 string to-be-printed
PRINT_STRING:
li $v0, 4
syscall
addi $sp, $sp, -4
sw $ra, ($sp)
jal PRINT_NEWLINE
lw $ra, ($sp)
addi $sp, $sp, 4
jr $ra

EXIT:
li $v0, 10
syscall

### restore the state of $ra
FINISH_RA:
lw $ra, ($sp)
addi $sp, $sp, 4
jr $ra

PRINT_NEWLINE:
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

### @param $a0 top of heap address
###        $a1 size
PRINT_HEAP:
move $t0, $a0           # heap address (top)
move $t1, $a1           # size of heap
beqz $t1, FINISH_RA     # break if $t1 == 0
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
j PRINT_HEAP