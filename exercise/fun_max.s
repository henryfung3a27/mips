# Input : 2 numbers from user
# Output: the larger/smaller number
#
#  MAX:
#   return (a >= b)? a : b
#  MIN:
#   return (a < b)? a : b

.data
ask_input_1 : .asciiz "Number 1: "
ask_input_2 : .asciiz "Number 2: "
max_result  : .asciiz " is larger"
min_result  : .asciiz " is smaller"
newline     : .asciiz "\n"

.text

main:
    # Receive input_1 ($t0)
    li $v0, 4
    la $a0, ask_input_1
    syscall
    li $v0, 5
    syscall
    move $t0, $v0   # a = $t0
    li $v0, 4
    la $a0, newline
    
    # Receive input_2 ($t1)
    li $v0, 4
    la $a0, ask_input_2
    syscall
    li $v0, 5
    syscall
    move $t1, $v0   # b = $t1
    li $v0, 4
    la $a0, newline
    
    # Compute 
    jal MIN         # result -> $v0
    
    # Print the result
    move $a0, $v0
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, result
    syscall
    la $a0, newline
    syscall
    
    li $v0, 10
    syscall

# return ($t0 >= $t1)? $t0 : $t1
MAX:
    sub $t2, $t0, $t1   # $t2 = $t0 - $t1 = a - b
    bgez $t2, Return_a  # if ($t2 >= 0) jump Return_a
    # Return $t1 (b)
    move $v0, $t1
    jr $ra
    # Return $t0 (a)
    Return_a:
        move $v0, $t0
        jr $ra

# return ($t0 < $t1)? $t0 : $t1
MIN:
    sub $t2, $t0, $t1   # $t2 = $t0 - $t1 = a - b
    bgtz $t2, Return_b  # if ($t2 < 0) jump Return_b
    # Return $t0 (a)
    move $v0, $t0
    jr $ra
    # Return $t1 (b)
    Return_b:
        move $v0, $t1
        jr $ra