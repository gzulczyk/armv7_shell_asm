.section .text
.global strip_newline
.global concat_strings

strip_newline:
    push {r1-r2, lr}
loop:
    ldrb r1, [r0], #1
    cmp r1, #0
    beq done
    cmp r1, #10
    bne loop
    mov r2, #0
    strb r2, [r0, #-1]
done:
    pop {r1-r2, pc}


concat_strings:
    push {r4-r7, lr}
    mov r5, r2

@ --- copy prefix "/bin" ---    
1:  ldrb r4, [r0], #1
    cmp r4, #0
    beq 2f
    strb r4, [r5], #1
    b 1b

@ --- copy declared command from buffer ---
2: ldrb r4, [r1], #1
   cmp r4, #0
   beq cmd_done
   cmp r4, #' '
   beq cmd_done
   strb r4, [r5], #1
   b 2b

cmd_done:
    mov r4, #0
    strb r4, [r5]
    str r2, [r3], #4

@ --- copy arguments from command to put it in argv because of execve logic ---
parse_args:
    ldrb r4, [r1], #1
    cmp r4, #' '
    beq parse_args
    cmp r4, #0
    beq end_args
    sub r1, r1, #1
    str r1, [r3], #4

scan_token:
    ldrb r4, [r1], #1
    cmp r4, #' '
    beq terminate_token
    cmp r4, #0
    beq end_args
    b scan_token

terminate_token:
    mov r4, #0
    strb r4, [r1, #-1]
    b parse_args

@ --- null-terminate args ---
end_args:
   mov r4, #0
   str r4, [r3]
   pop {r4-r7, pc}