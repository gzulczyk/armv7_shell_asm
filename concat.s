.section .text          @ code section
.global strip_newline   @ function "strip_newline" globally available
.global concat_strings  @ function "concat_strings" globally available

strip_newline:
    push {r1-r2, lr}    @ keep r1, r2 register and link register
loop:
    ldrb r1, [r0], #1   @ load byte from r0, keep it in r1 and advance it by +1
    cmp r1, #0          @ compare does register r0 has null-terminator inside (0x00)
    beq done            @ if so, strip is complete, go to the `done` section
    cmp r1, #10         @ compare does register r1 has newline sign
    bne loop            @ if not equal, keep loop
    mov r2, #0          @ if so, set r2 as 0x00
    strb r2, [r0, #-1]  @ write the byte to the r2 register with r0 value, change pointer to -1
done:
    pop {r1-r2, pc}     @ return r1,r2, pc back 


concat_strings:
    push {r4-r7, lr}    @ keep r4-r7 registers and link register
    mov r5, r2          @ set r2 value into r5 register

@ --- copy prefix "/bin" ---    
1:  ldrb r4, [r0], #1   @ load byte from r0, keep it in 42 and advance it by +1
    cmp r4, #0          @ compare does r4 has null-terminator inside
    beq 2f              @ if so, go to 2: section
    strb r4, [r5], #1   @ if not, write the r5 value inside and before that go back by -1 
    b 1b                @ go to the beginning

@ --- copy declared command from buffer ---
2: ldrb r4, [r1], #1    @ load byte from r1, keep it in r4 and advance it by +1
   cmp r4, #0           @ compare does r4 has null-terminator inside
   beq cmd_done         @ if so, command is created properly, go to the `cmd_done` section
   cmp r4, #' '         @ if not, compare does r4 has whitespace inside 
   beq cmd_done         @ if so, command is created properly, go to the `cmd_done` section
   strb r4, [r5], #1    @ load byte from r5, keep it in r4 and advance it by +1
   b 2b                 @ go to the 2: section

cmd_done:
    mov r4, #0          @ set 0x00 value inside r4 register
    strb r4, [r5]       @ store the r5 address inside r4 register
    str r2, [r3], #4    @ 

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