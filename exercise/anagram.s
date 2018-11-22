# Return the number of anagrams of s in the list L
# using merge sort

	.data
	.align 2
k:      .word   4       # include a null character to terminate string
s:      .asciiz "bac"
n:      .word   6
L:      .asciiz "abc"
        .asciiz "bbc"
        .asciiz "cba"
        .asciiz "cde"
        .asciiz "dde"
        .asciiz "dec"
nl:     .asciiz "\n"
    .text
### ### ### ### ### ###
### MainCode Module ###
### ### ### ### ### ###
main:
    li $t9,4                # $t9 = constant 4
    
    lw $s0,k                # $s0: length of the key word
    la $s1,s                # $s1: key word
    lw $s2,n                # $s2: size of string list
    
# sort key word
    li $a2, 0               # $a2: left of merge_sort (0)
    subi $a3, $s0, 2        # $a3: right of metge_sort (k-2)
    move $s7, $s1           # $s7: key word
    jal MERGE_SORT
    move $s1, $s7           # $s1 = sortted key word
# allocate heap space for string array:    
    li $v0,9                # syscall code 9: allocate heap space
    mul $a0,$s2,$t9         # calculate the amount of heap space
    syscall
    move $s3,$v0            # $s3: base address of a string array
# record addresses of declared strings into a string array:  
    move $t0,$s2            # $t0: counter i = n
    move $t1,$s3            # $t1: address pointer j 
    la $t2, L               # $t2: address of declared list L
    li $s4, 0               # $s4: result counter
READ_DATA:
    blez $t0,FIND           # if i>0, read string from L
    sw $t2,($t1)            # put the address of a string into string array.
    
    addi $t0,$t0,-1
    addi $t1,$t1,4
    add $t2,$t2,$s0
    j READ_DATA

FIND:
    beqz $s2, PRINT_RESULT      # jump PRINT_RESULT if $t0==$s2 (i == n)
    li $a2, 0                   # $a2: left of merge_sort  (0)
    subi $a3, $s0, 2            # $a3: right of merge_sort (k-2)
    lw $s7, ($s3)               # $s7: the string to be sorted
    addi $s2, $s2, -1           # decrement $s2 (size of list L)
    addi $s3, $s3, 4            # increment $s3 for loading word
    
    jal MERGE_SORT              # return string -> $s7
# compare the sortted string and sortted key word
    move $a0, $s7               # $a0: sortted word from list
    move $a1, $s1               # $a1: sortted key word
    subi $a2, $s0, 1            # $a2: length of strings (k-1)
    jal COMPARE                 # return value -> $a0
    add $s4, $s4, $a0           # result counter += $a0 (1 if equal, 0 otherwise)
    j FIND

### print the result counter
PRINT_RESULT:
    move $a0, $s4           # $s4: result counter
    li $v0, 1               # print int
    syscall
    j EXIT                  # exit the program

### @param $s7 input string in heap
#          $a2 left
#          $a3 right
MERGE_SORT:
    sub $t0, $a3, $a2           # $t0 = right - left
    addi $sp, $sp, -4           # store the state of $ra
    sw $ra, ($sp)
    beqz $t0, FINISH_RA         # if left >= right return
# split the string into 2
    li $t1, 2                   # $t1 = constant 2
    add $t0, $a2, $a3           # $t0 = left + right
    div $t0, $t0, $t1           # $t0 = (left + right) / 2
    mflo $t0                    # $t0 = quotient of result (mid)
    addi $sp, $sp, -12          # allocate 3 word spaces
    sw $t0, ($sp)               # 0($sp) = mid
    sw $a2, 4($sp)              # 4($sp) = left
    sw $a3, 8($sp)              # 8($sp) = right
# MERGE_SORT LHS of array
    move $a2, $a2               # $a2 = left
    move $a3, $t0               # $a3 = mid
    jal MERGE_SORT
# MERGE_SORT RHS of array
    lw $a2, 0($sp)              # load mid from stack
    addi $a2, $a2, 1            # $a2 = mid+1
    lw $a3, 8($sp)              # $a3 = right (load from stack)
    jal MERGE_SORT
# MERGING
    move $a0, $s0               # create result heap with size k
    li $v0, 9
    syscall
    move $s6, $v0               # $s6 = base of result heap
# create heap for left_array
    move $a0, $s0               # size of sub-array (k)
    li $v0, 9
    syscall
    move $t4, $v0               # always point to base of left-heap
    move $t5, $v0               # for CREATE_LEFT to increment
# create heap for right_array
    li $v0, 9
    syscall
    move $t6, $v0               # always point to base of right-heap
    move $t7, $v0               # for CREATE_RIGHT to incrementlw $a0, 4($sp)
    
    lw $a0, 4($sp)              # $a0 = left
    lw $a1, 0($sp)
    addi $a1, $a1, 1            # $a1 = mid+1
    lw $a2, 8($sp)              # $a2 = right
# insert char into left heap from left to mid
CREATE_LEFT:
    sub $t0, $a0, $a1           # $t0 = $a0 - $a1 = left - (mid+1)
    beqz $t0, CREATE_RIGHT
    add $t0, $s7, $a0           # $t0 = str + left
    lb $t0, ($t0)               # $t0 = str[left]
    sb $t0, ($t5)               # store $t0 to $t5
    addi $t5, $t5, 1            # increment $t5 (heap)
    addi $a0, $a0, 1            # increment $a0 (left)
    j CREATE_LEFT
# insert char into right heap from mid+1 to right
CREATE_RIGHT:
    sub $t0, $a1, $a2           # $t0 = $a1 - $a2 = (mid+1) - right
    subi $t0, $t0, 1            # $t0 = $t0 - 1
    beqz $t0, DONE_CREATE
    add $t0, $s7, $a1           # $t0 = str + (mid+1)
    lb $t0, ($t0)               # $t0 = str[mid+1]
    sb $t0, ($t7)               # store $t0 to $t7
    addi $t7, $t7, 1            # increment $t7 (heap)
    addi $a1, $a1, 1            # increment $a1 (mid+1)
    j CREATE_RIGHT
# call MERGING with
# $a0 = base of heap of left-array (null-terminated)
# $a1 = base of heap of right-array (null-terminated)
# $a2 = base of result heap (null-terminated on return by MERGING)
DONE_CREATE:
    move $a0, $t4               # $a0 = base of left heap
    move $a1, $t6               # $a1 = base of right heap
    move $a2, $s6               # $a2 = base of result heap
    jal MERGING

# insert the result heap into input heap
    move $a0, $s6               # $a0 = base of result heap
    lw $t0, 4($sp)              # $t0 = left of string
    lw $t1, 8($sp)              # $t1 = right of string
    move $t2, $s7               # $t2 = base of input string
    add $t2, $t2, $t0           # $t2 = pointer to left of input string
                                #     = string[left]
INSERT_INTO_HEAP:
    lb $t3, ($a0)               # $t3 = byte from result heap
    beqz $t3, FINISH_INSERT     # if $t3=0 then finish
    sb $t3, ($t2)               # store the byte to ($t2) string[left]
    addi $a0, $a0, 1            # increment result heap address
    addi $t2, $t2, 1            # increment input string address
    j INSERT_INTO_HEAP
FINISH_INSERT:
    addi $sp, $sp, 12           # free stack with left, mid and right
    j FINISH_RA

    
# @param $a0 base of string_1 heap
#        $a1 base of string_2 heap
#        $a2 base of result heap
# after merging, $a2 will point to \0
# e.g. $a2 = [1, 2, 3, 4, 5, 6, \0]
#                                ^ here
MERGING:
    lb $t0, ($a0)           # $t0 = str1[0] 
    lb $t1, ($a1)           # $t1 = str2[0]
    beqz $t0, MERGE_STR2    # chech if one of the first char
    beqz $t1, MERGE_STR1    # is \0, branch if yes
# compare
    ble $t0, $t1, CHOOSE_1  # jump CHOOSE_1 if $t0 <= $t1
# CHOOSE_2:
    sb $t1, ($a2)           # store byte to $a2 (result heap)
    addi $a2, $a2, 1        # increment result heap address
    addi $a1, $a1, 1        # increment str2 address
    j MERGING
CHOOSE_1:
    sb $t0, ($a2)           # store byte to $a2
    addi $a2, $a2, 1        # increment result heap address
    addi $a0, $a0, 1        # increment str2 address
    j MERGING   

### merge the remaining elements in str1
MERGE_STR1:
    lb $t0, ($a0)               # $t0 = load byte from $a0 (str1)
    beqz $t0, FINISH_MERGING    # return if $t0 = 0 (\0)
    sb $t0, ($a2)               # store $t0 to $a2 (result heap)
    addi $a2, $a2, 1            # increment result heap address
    addi $a0, $a0, 1            # increment str1 address
    j MERGE_STR1

### merge the remaining elements in str2
MERGE_STR2:
    lb $t0, ($a1)               # $t0 = load byte from $a1 (str2)
    beqz $t0, FINISH_MERGING    # return if $t0 = 0 (\0)
    sb $t0, ($a2)               # store $t0 to $a2 (result heap)
    addi $a2, $a2, 1            # increment result heap address
    addi $a1, $a1, 1            # increment str2 address
    j MERGE_STR2

### put null char to the end of result heap
FINISH_MERGING:
    sb $zero, ($a2)
    jr $ra

### compare two strings (key string and string)
# @param  $a0 base of heap_1
#         $a1 base of heap_2
#         $a2 size
# @return $a0 0 if equal, 1 otherwise
COMPARE:
    beqz $a2, EQUAL             # return EQUAL if size=0
# size -= 1
    addi $a2, $a2, -1
# a0[0] - a1[0]
    lb $t0, ($a0)               # $t0 = $a0 (first byte)
    lb $t1, ($a1)               # $t1 = $a1 (first byte)
    sub $t0, $t0, $t1           # $t0 = $t0 - $t1
    bne $t0, $zero, NOT_EQUAL   # return NOT_EQUAL if $t0 != 0
    addi $a0, $a0, 1            # increment pointer $a0
    addi $a1, $a1, 1            # increment pointer $a1
# recurse
    j COMPARE
EQUAL:
    li $a0, 1                   # $a0 = 1
    jr $ra
NOT_EQUAL:
    li $a0, 0                   # $a1 = 0
    jr $ra

# this sub-routine helps recover the state of $ra
# stored in stack and jr it
FINISH_RA:
    lw $ra, ($sp)
    addi $sp, $sp, 4
    jr $ra

# @param $a0 base of heap address
#        $a1 size
PRINT_HEAP:
    beqz $a1, FINISH_PRINT_HEAP    # if size=0 return
    addi $sp, $sp, -8
    sw $a0, 0($sp)          # store the state of $a0
    sw $ra, 4($sp)          # store the state of $ra
    lb $a0, ($a0)           # n
    li $v0, 1              # |> print byte
    syscall                 # u
    lw $a0, ($sp)           # restore the state of $a0
    addi $sp, $sp, 4
    addi $a0, $a0, 1        # increment pointer of heap
    addi $a1, $a1, -1       # decrement the size
    j PRINT_HEAP
FINISH_PRINT_HEAP:
    la $a0, nl
    li $v0, 4
    syscall
    j FINISH_RA
    
EXIT:
    li $v0, 10
    syscall
