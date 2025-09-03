.section .rodata
end_string: .asciz "endShell"

.section .text
.global check_terminate
.extern buffer

check_terminate:
    push {r4,r7, lr}
    ldr r1, =buffer
1:  ldrb r2,[r1], #1
    cmp r2, #' '
    beq 1b
    subs r1,r1, #1
    ldr r0, =end_string

2:  ldrb r3, [r0], #1
    cmp r3, #0
    beq 3f
    ldrb r2, [r1]
    cmp r2, r3
    bne not_match
    add r1,r1, #1
    b 2b

3: ldrb r2, [r1]
   cmp r2, #0
   beq do_exit
   cmp r2, #' '
   beq do_exit
   cmp r2, #9
   beq do_exit
   cmp r2, #10
   beq do_exit
   cmp r2, #13
   beq do_exit
   b not_match

do_exit:
    mov r0, #1
    pop {r4, r7,pc}

not_match:
    pop {r4,r7, pc}