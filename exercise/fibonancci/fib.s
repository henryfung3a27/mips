###
# Print fib sequence from 0 to n in O(n)
###
# 1. Create a heap of size (round up n to nearest multiple of 4)
# 2. Insert all fab numbers from 0 to n to the heap
# 3. Print one by one
###

    .data
ask_for_input   :   .asciiz "Input an integer: "
newline         :   .asciiz "\n"
colon           :   .asciiz "  : "
    .text

main:
    li $t9, 4               # $t9 = constant 4 (bytes for int)
# Ask for input and store it to $s0
    la $a0, ask_for_input   # $a0 = ask_for_input
    li $v0, 4               # code 4: print string
    syscall
    li $v0, 5               # code 5: read int (result in $v0)
    syscall
    bltz $v0, EXIT          # exit if input value < 0
    move $s0, $v0           # $s0 = input int (n)
# Calculate heap size needed for fib sequence
    move $a0, $v0           # $a0 = $v0 = n
    jal CALCULATE_HEAP_SIZE # $a0 = round n up to multiple of 4
# Create fib sequence heap
    li $v0, 9
    syscall
    move $s1, $v0           # $s1 = base address of fib sequence heap
# Generate fib sequence
    move $a0, $s0           # $a0 = $s0 = n
    move $a1, $s1           # $a1 = $s1 = base of fib sequence heap
    move $a2, $zero         # $a2 = 0 = current number of fib
    jal GENERATE_FIB
# Print the values in the result heap
    move $a0, $s0
    move $a1, $s1
    jal PRINT_HEAP
# Exit safely
EXIT:
    li $v0, 10
    syscall

#####
# Generate a sequence of Fib number up to n
#####
# param:
#   $a0 n (number of fib number to generate)
#   $a1 base of result heap
#   $a2 current number of fib
#####
GENERATE_FIB:
    sub $t0, $a0, $a2       # $t0 = n - current
    beqz $t0, FINISH_GEN    # if $t0 = 0, return to caller
    beqz $a2, INSERT_ZERO   # if $a2 = 0, insert zero to heap
    addi $t0, $a2, -1       # $t0 = current - 1
    beqz $t0, INSERT_ONE    # if $t0 = 0 ($a2 = 1), insert one to heap
    addi $t1, $a2, -2       # $t1 = current - 2
# Get the value of fib[current-1] and fib[current-2] from heap    
    mul $t0, $t0, $t9       # $t0 *= 4 bytes of int
    mul $t1, $t1, $t9       # $t1 *= 4 bytes of int
    add $t0, $s1, $t0       # $t0 = address of fib[current-1]
    add $t1, $s1, $t1       # $t1 = address of fib[current-2]
    lw $t0, ($t0)           # $t0 = fib[current-1]
    lw $t1, ($t1)           # $t1 = fib[current-2]
# Store the sum of fib[current-1] and fib[current-2] to heap
    add $t0, $t0, $t1       # $t0 = fib[current-1] + fib[current-2]
    sw $t0, ($a1)           # store $t0 to result heap
# Increment address of heap and current
    add $a1, $a1, $t9       # increment address of result heap (+4)
    addi $a2, $a2, 1        # increment current n'th fib number
    j GENERATE_FIB
# Insert 0 to fib sequence heap
INSERT_ZERO:
    li $t0, 0				# $t0 = 0
    sw $t0, ($a1)           # ($a1) = 0
    add $a1, $a1, $t9       # $a1 += 4 (pointer to result heap + 4)
    addi $a2, $a2, 1        # $a2 += 1 (current += 1)
    j GENERATE_FIB
# Insert 1 to fib sequence heap
INSERT_ONE:
    li $t0, 1				# $t0 = 1
    sw $t0, ($a1)           # ($a1) = 1
    add $a1, $a1, $t9       # $a1 += 4 (pointer to result heap + 4)
    addi $a2, $a2, 1        # $a2 += 1 (current += 1)
    j GENERATE_FIB
# Return to caller after finishing GENERATE_FIB
FINISH_GEN:
    jr $ra

#####
# Calculate the heap size needed for n
# in multiple of 4
#####
# param:
#   $a0 n
# output:
#   $a0 size (multiple of 4)
#####
CALCULATE_HEAP_SIZE:
    div $t1, $a0, $t9   # $t1 = n // 4
    addi $t1, $t1, 1    # $t1 = $t1 + 1
    mul $t1, $t1, $t9   # $t1 = $t1 * 4
    move $a0, $t1       # $a0 = $t1 (number of elements)
    mul $a0, $a0, $t9   # $a0 = num of elements * 4 bytes per int
    jr $ra

#####
# Return to caller
# Caller address get from stack
#####
RETURN_RA_S:
    lw $ra, ($sp)
    addi $sp, $sp, 4
    jr $ra

#####
# Print the content of the heap in int
#####
# param:
#   $a0 number of elements to be printed
#   $a1 base of the heap
#####
PRINT_HEAP:
    li $t0, 0
_PRINT_HEAP:
    beq $a0, $t0, FINISH_PRINT_HEAP
# store $a0 to stack
    addi $sp, $sp, -4
    sw $a0, ($sp)
# print the nth number
    addi $a0, $t0, 1
    li $v0, 1
    syscall
# print colon
    la $a0, colon
    li $v0, 4
    syscall
# print value
    lw $a0, ($a1)
    li $v0, 1
    syscall
# print newline
    la $a0, newline
    li $v0, 4
    syscall
# restore $a0 from stack
    lw $a0, ($sp)
    addi $sp, $sp, 4
    addi $t0, $t0, 1
    add $a1, $a1, $t9
    j _PRINT_HEAP
FINISH_PRINT_HEAP:
    jr $ra
