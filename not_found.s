.section .rodata                @ read only data section
msg_not_found: .asciz "X shell cannot find that command, do ls -la /bin/ to see supported commands!\n"

.section .text                  @ code section
.global not_found               @ make function `not_found` globally available

not_found:
    push {r4, lr}               @ keep the r4 register and link register
    ldr r1, =msg_not_found      @ load the start point of label `msg_not_found`
    mov r2, #0                  @ set 0 for the r2 register (register indexer, it gonna iterate through whole msg_not_found string)
1:  ldrb r3, [r1,r2]            @ load 1 byte from memory at address (r1 + r2) into r3
    cmp r3, #0                  @ check does it has null-terminator
    beq 2f                      @ if so, go to the 2: section and try to write the not_found output
    add r2, r2, #1              @ if not, iterate through next char
    b 1b                        @ loop iterating through letter
2:  mov r7, #4                  @ set the write syscall
    mov r0, #2                  @ set the stderr
    mov r1, r1                  @ pointer to string
    mov r2, r2                  @ length of not_found message
    svc #0                      @ execute
    pop {r4, pc}                @ return back the r4 and pc 