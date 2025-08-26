.section .data
buffer: .space 256

.section .text
.global read_input

read_input:
    push {r7, lr}
    ldr r1, =buffer
    mov r2, #256
    mov r7, #3
    mov r0, #0
    svc #0
    pop {r7, pc}
