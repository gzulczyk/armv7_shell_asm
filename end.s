.section .rodata                @ read-only data section
end_string: .asciz "endShell"   @ the builtin command that terminates the shell

.section .text                  @ start of code section
.global check_terminate         @ export `check_terminate` for use in other files
.extern buffer                  @ buffer is defined elsewhere (global input buffer)

check_terminate:
    push {r4,r7, lr}            @ keep register r4, r7 and link register
    ldr r1, =buffer             @ r1 = addres of input buffer

1:  ldrb r2,[r1], #1            @ load byte from buffer into r2, advance pointer by +1 
    cmp r2, #' '                @ check does it is a whitespace char
    beq 1b                      @ if so, keep looping
    subs r1,r1, #1              @ undo the last increment so r1 points to first non-space
    ldr r0, =end_string         @ load the address of `end_string`

2:  ldrb r3, [r0], #1           @ load byte from end_string into r3, advance pointer by +1
    cmp r3, #0                  @ check does it is a 0x00 aka '\0'
    beq 3f                      @ if so, string fully matched and go to the 3: section
    ldrb r2, [r1]               @ load byte from buffer 
    cmp r2, r3                  @ compare buffer byte with end_string byte
    bne not_match               @ mismatch, go to not_match
    add r1,r1, #1               @ advance buffer pointer
    b 2b                        @ loop until end_string ends

3: ldrb r2, [r1]                @ load the next buffer byte
   cmp r2, #0                   @ check does it have null-terminator
   beq do_exit                  @ if so, terminate program
   cmp r2, #' '                 @ check does it have whitespace
   beq do_exit                  @ if so, terminate program
   cmp r2, #9                   @ check does it have horizontal tab 
   beq do_exit                  @ if so, terminate program
   cmp r2, #10                  @ check does it have newline 
   beq do_exit                  @ if so, terminate program
   cmp r2, #13                  @ check does it have carriage return
   beq do_exit                  @ if so, terminate program
   b not_match                  @ if any other character follows, not match

do_exit:
    mov r0, #1                  @ signal match return, it will be used later as return value 
    pop {r4, r7,pc}             @ return back the r4, r7 and pc values

not_match:
    mov r0, #0                  @ signal not_match return 
    pop {r4,r7, pc}             @ return back the r4, r7 and pc values