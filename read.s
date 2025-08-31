.section .text
.global read_input
.extern buffer 

read_input:
    push {r7, lr}
    ldr r1, =buffer
    mov r2, #255
    mov r7, #3
    mov r0, #0
    svc #0
    add r1, r1, r0
    mov r2,#0
    strb r2, [r1]
    pop {r7, pc}
