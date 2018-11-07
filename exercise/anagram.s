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
    la $t2,L                # $t2: address of declared list L
    li $t3, 0               # $t3: result counter
READ_DATA:
    blez $t0,FIND           # if i >0, read string from L
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
    lw $t5, ($t1)               # $t5: the string to be sorted
    jal MERGE_SORT              # return string -> $a0
    jal COMPARE                 # return value -> $a0
    bne $a0, $zero, FIND        # if $a0 != 0, recurse
    addi $t3, $t3, 1            # result counter += 1
    j FIND

### input string: $t5
MERGE_SORT:
    move $t6, $zero             # $t6: left  (0)
    addi $t7, $s0, -1           # $t7: right (3)
    
MERGING:
    addi $v0, $v0, 0
    
### compare two strings (key string and string)
### input: $a0
### output: $a0 (0 for equal, 1 otherwise)
COMPARE:
    
### print the result counter
PRINT_RESULT:
    move $a0, $t3           # $t3: result counter
    li $v0, 1
    syscall
    j EXIT                  # exit the program
    
EXIT:
    li $v0, 10
    syscall
    
    
    
    
    
    
    
    
    
    
    
    