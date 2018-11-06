.data
.align 2
str: .asciiz "Hello, "
buffer: .space 16   # allocate byte space for a buffer

.text

main:
  # Accept input string from user
  li $v0, 8         # read string
  la $a0, buffer    # load byte space into address
  li $a1, 16        # allot the byte space for string
  syscall
  move $t0, $a0
  
  # Print "Hello, "
  li $v0, 4         # print string
  la $a0, str
  syscall
  
  # Print the input string
  li $v0, 4         # print string
  move $a0, $t0     # move input string to $a0
  syscall
  
  # Exit
  li $v0, 10
  syscall