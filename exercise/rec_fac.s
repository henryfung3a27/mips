.data
x: .word 4

.text

main:
lw $a0, x           # $a0 = x
li $v0, 1           # result($v0) = 1
jal FAC             # call FAC
add $a0, $zero, $v0 # $a0 = $v0
li $v0, 1
syscall             # print $a0 (result)

li $v0, 10
syscall


FAC:
# store the state
addi $sp, $sp, -4
sw $ra, 0($sp)
#sw $s0, 4($sp)

# check $a0 <= 1
addi $s0, $a0, 0        # $s0 = $a0(x)
subi $t0, $s0, 1        # $t0 = $s0 - 1 (to compare)
blez $t0, EXIT_FAC      # ($t0 <= 1) -> return_ans

# calculate
mul $v0, $v0, $s0       # res = res * $s0
subi $a0, $a0, 1        # $a0(x) -= 1
jal FAC

EXIT_FAC:
# Restore the state of $ra
lw $ra, 0($sp)
#lw $s0, 4($sp)
addi $sp, $sp, 4
jr $ra

# In line 20 and 38, the 4 can be changed to 8 and
# uncomment line 22 and 37.
# Not sure the meaning of storing the state
# of $s0 yet
