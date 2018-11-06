.data
str_after_sum: .asciiz "After addition, result="
str_after_sub: .asciiz "After substraction, result="
str_after_mul: .asciiz "After multiplication, result="
newline      : .asciiz "\n"

.text

main:
    li $t5, 3       # a
    li $t6, 4       # b
    li $t7, 5       # c
    
    ### SUMMATION ###
    jal SUM         # call the function
    
    move $t0, $v0   # result after addition
    la $a0, str_after_sum
    li $v0, 4
    syscall
    move $a0, $t0
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    
    ### SUBSTRACTION ###
    jal SUB
    
    move $t0, $v0
    la $a0, str_after_sub
    li $v0, 4
    syscall
    move $a0, $t0
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    
    ### MULTIPLICATION ###
    jal MUL
    
    move $t0, $v0
    la $a0, str_after_mul
    li $v0, 4
    syscall
    move $a0, $t0
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    
    li $v0, 10
    syscall
    
SUM:
    add $t0, $t5, $t6
    add $v0, $t0, $t7
    jr $ra          # $ra stores the address return address (line 15)
                    # PC now point to line 17
                    
SUB:
    sub $t0, $t5, $t6   # in register, the result is stored in
    sub $v0, $t0, $t7   # 32 bit unsigned.
    jr $ra              # -6 is stored as 4294967290
                        # i.e. 2^32 - 6
                        
MUL:
    mul $t0, $t5, $t6
    mul $v0, $t0, $t7
    jr $ra