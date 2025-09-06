.section .text                  @ code section
.global strip_newline           @ function "strip_newline" globally available
.global concat_strings          @ function "concat_strings" globally available

@ --- replace the first newline '\n' in buffer with '\0' (so input ends cleanly) ---
strip_newline:
    push {r1-r2, lr}            @ keep r1, r2 register and link register
loop:
    ldrb r1, [r0], #1           @ load byte from r0, keep it in r1 and advance it by +1
    cmp r1, #0                  @ compare does register r1 has null-terminator inside (0x00)
    beq done                    @ if so, strip is complete, go to the `done` section
    cmp r1, #10                 @ compare does register r1 has newline sign
    bne loop                    @ if not equal, keep loop
    mov r2, #0                  @ if so, set r2 as 0x00
    strb r2, [r0, #-1]          @ overwrite `\n` with the `\0` flag because of step back via -1
done:
    pop {r1-r2, pc}             @ return r1,r2, pc back 


concat_strings:
    push {r4-r7, lr}            @ keep r4-r7 registers and link register
    mov r5, r2                  @ set r2 value into r5 register

@ --- copy prefix "/bin" ---    
1:  ldrb r4, [r0], #1           @ load byte from r0, keep it in r4 and advance it by +1
    cmp r4, #0                  @ compare does r4 has null-terminator inside
    beq 2f                      @ if so, go to 2: section
    strb r4, [r5], #1           @ if not, store byte from r4 into the memory pointed to by r5 then advance r5 to the next byte in the destination
    b 1b                        @ go to the beginning of 1:

@ --- copy declared command from buffer ---
2: ldrb r4, [r1], #1            @ load byte from r1, keep it in r4 and advance it by +1 (that's the buffer string iteration byte by byte)
   cmp r4, #0                   @ compare does r4 has null-terminator inside
   beq cmd_done                 @ if so, command is created properly, go to the `cmd_done` section
   cmp r4, #' '                 @ if not, compare does r4 has whitespace inside 
   beq cmd_done                 @ if so, command is created properly, go to the `cmd_done` section (because arguments gonna be placed in argv[1], argv[2] section)
   strb r4, [r5], #1            @ if not, store byte from r4 into the memory pointed to by r5 and advance it by +1 
   b 2b                         @ go to the 2: section

cmd_done:
    mov r4, #0                  @ set 0x00 value inside r4 register
    strb r4, [r5]               @ store 0x00 byte (null terminator) into the memory location pointed to by r5
    str r2, [r3], #4            @ store the r2 value at memory address which r3 points to and advance it by 4 (argv[0] = /bin/$command\0 + advance by 4 makes argv[1], so we re ready to providing arguments to the 2nd place in argv array)

@ --- copy arguments from command to put it in argv because of execve logic ---
parse_args:
    ldrb r4, [r1], #1           @ load byte from r1 and keep it inside r4 and advance it by +1
    cmp r4, #' '                @ compare does r4 has whitespace on it
    beq parse_args              @ if so, go to `parse_args` function
    cmp r4, #0                  @ if not, compare does it has null-terminator inside
    beq end_args                @ if so, go to the `end_args` function
    sub r1, r1, #1              @ if not, r1 = r1-1
    str r1, [r3], #4            @ store the r1 value at memory address which r3 points to and advance it by 4

scan_token:
    ldrb r4, [r1], #1           @ load byte from r1 and keep it in r4, advance by +1
    cmp r4, #' '                @ compare does r4 has whitespace on it
    beq terminate_token         @ if so, go to the `terminate_token` function
    cmp r4, #0                  @ compare doest r4 has null-terminator
    beq end_args                @ if so, go to the `end_args` function
    b scan_token                @ if not, go to the `scan_token`

terminate_token:
    mov r4, #0                  @ set 0x00 into r4 register
    strb r4, [r1, #-1]          @ store the value in r4 at address (r1 - 1), so one argument is already terminated like "-l\0" and we modify the original buffer,
                                @ with replacing whitespace " " with "\0" instead of copying into new memory, which would be wasteful
    b parse_args                @ go to the `parse_args` function and parse next argument

@ --- null-terminate args ---
end_args:
   mov r4, #0                   @ set 0x00 value into r4 register
   str r4, [r3]                 @ store r4 value (0) into argv[] slot, marks end of all args for execve
   pop {r4-r7, pc}              @ return back r4-r7 and pc
