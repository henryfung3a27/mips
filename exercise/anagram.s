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
	
    .text
### ### ### ### ### ###
### MainCode Module ###
### ### ### ### ### ###
main:
    li $t9,4                # $t9 = constant 4
    
    lw $s0,k                # $s0: length of the key word
    la $s1,s                # $s1: key word
    lw $s2,n                # $s2: size of string list
    
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
### write your code ###
    beq $t0, $s2, PRINT_RESULT  # jump PRINT_RESULT if $t0==$s2 (i == n)
    addi $t0, $t0, 1            # increment $t0 (size)
    addi $t1, $t1, -4           # decrement $t1 for loading word
    li $a2, 0                   # left of merge_sort  (0)
    subi $a3, $s0, 2            # right of merge_sort (k-2)
    lw $t5, ($t1)               # $t5: the string to be sorted
    jal MERGE_SORT              # return string -> $a0
    jal COMPARE                 # return value -> $a0
    bne $a0, $zero, FIND        # if $a0 != 0, recurse
    addi $s4, $s4, 1            # result counter += 1
    j FIND

### @param $t5 input string in heap
#          $a2 left
#          $a3 right
MERGE_SORT:
    sub $t0, $a2, $a3           # $t0 = left - right
    bgez $t0, RETURN_RA         # if left >= right return
# split the string into 2
    li $t1, 2                   # $t1 = constant 2
    add $t0, $a2, $a3           # $t0 = left + right
    div $t0, $t0, $t1           # $t0 = (left + right) / 2
    mflo $t0                    # $t0 = quotient of result (mid)
    addi $sp, $sp, -12
    sw $t0, ($sp)
    
    
    
RETURN_RA:
    jr $ra
    
# @param $a0 base of string_1 heap
#        $a1 base of string_2 heap
#        $a2 result heap
# after merging, $a2 will point to \0
# e.g. $a2 = [1, 2, 3, 4, 5, 6, \0]
#                                ^ here
MERGING:
    lb $t0, ($a0)           # $t0 = str1[0] 
    lb $t1, ($a1)           # $t1 = str2[0]
    beqz $t0, MERGE_STR2    # chech if one of the first char
    beqz $t1, MERGE_STR1    # is \0, branch if yes
# store $ra
    addi $sp, $sp, -4
    sw $ra, ($sp)
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
    beqz $t0, FINISH_MERGE      # return if $t0 = 0 (\0)
    addi $sp, $sp, -4           # store $ra
    sw $ra, ($sp)
    sb $t0, ($a2)               # store $t0 to $a2 (result heap)
    addi $a2, $a2, 1            # increment result heap address
    addi $a0, $a0, 1            # increment str1 address
    j MERGE_STR1

### merge the remaining elements in str2
MERGE_STR2:
    lb $t0, ($a1)               # $t0 = load byte from $a1 (str2)
    beqz $t0, FINISH_MERGE      # return if $t0 = 0 (\0)
    addi $sp, $sp, -4           # store $ra
    sw $ra, ($sp)
    sb $t0, ($a2)               # store $t0 to $a2 (result heap)
    addi $a2, $a2, 1            # increment result heap address
    addi $a1, $a1, 1            # increment str2 address
    j MERGE_STR2

### put null char to the end of result heap
FINISH_MERGE:
    sb $zero, ($a2)
    j FINISH_RA

### compare two strings (key string and string)
# @param  $a0 base of heap_1
#         $a1 base of heap_2
#         $a2 size
# @return $a0 0 if equal, 1 otherwise
COMPARE:
    beqz $a2, EQUAL             # return EQUAL if size=0
# store $ra
    addi $sp, $sp, -4
    sw $ra, ($sp)
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
    li $a0, 0                   # $a0 = 0
    j FINISH_RA
NOT_EQUAL:
    li $a0, 1                   # $a1 = 1
    j FINISH_RA

# this sub-routine helps recover the state of $ra
# stored in stack and jr it
FINISH_RA:
    lw $ra, ($sp)
    addi $sp, $sp, 4
    jr $ra

### print the result counter
PRINT_RESULT:
    move $a0, $s4           # $t3: result counter
    li $v0, 1               # print int
    syscall
    j EXIT                  # exit the program
    
# @param $a0 input string
#        $a1 base address of result heap
# the last element in the heap will be 0 and points to it
# i.e. $a1 = [1, 2, 3, 0] for size 4
#                      ^ $a1 points here at the end
TO_HEAP:
    lb $t0, ($a0)           # $t0: load byte from string
    addi $sp, $sp, -4       # store the state of $ra
    sw $ra, ($sp)
    sb $t0, ($a1)           # store the byte from $t0 to $a1
    addi $a0, $a0, 1        # increment $a0 (string pointer)
    addi $a1, $a1, 1        # increment $a1 (heap pointer)
    beqz $t0, FINISH_RA     # return if $t0 = 0 so that 
                            # 0 will be stored before returning
    j TO_HEAP

# @param $a0 base of heap address
#        $a1 size
PRINT_HEAP:
    beqz $a1, FINISH_RA     # if size=0 return
    addi $sp, $sp, -8
    sw $a0, 0($sp)          # store the state of $a0
    sw $ra, 4($sp)          # store the state of $ra
    lb $a0, ($a0)           # n
    li $v0, 11              # |> print byte
    syscall                 # u
    lw $a0, ($sp)           # restore the state of $a0
    addi $sp, $sp, 4
    addi $a0, $a0, 1        # increment pointer of heap
    addi $a1, $a1, -1       # decrement the size
    j PRINT_HEAP
    
EXIT:
    li $v0, 10
    syscall