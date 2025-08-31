.section .rodata, "a", %progbits
.balign 4

msg_not_found: .asciz "X shell cannot find that command, do ls -la /bin/ to see supported commands!\n"

.section .text 
.global not_found 
.type not_found, %function

not_found:
    push {r4, lr}
    ldr r1, =msg_not_found
    mov r2, #0
1:  ldrb r3, [r1,r2]
    cmp r3, #0
    beq 2f
    add r2, r2, #1
    b 1b
2:  mov r7, #4
    mov r0, #2
    svc #0
    pop {r4, pc}