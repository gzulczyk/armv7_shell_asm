.section .data @ data section for variables and static data
prompt: .asciz "X " @ declaration of ascii sign of our shell, i decied to make anothar than Ed from LLTV and i use X instead of dolar sign :) 

.section .text @ code section, place where instructions go
.global display_prompt @ declaration of program start point
.global print_string

display_prompt: 
    push {lr} @ save the point of main func
    ldr r0, =prompt  @ load in r0 register address of "X "
    bl print_string @ switch to the print_string function
    pop {pc} @ go back to the main func via using the lr saved in the beginning in that declared func

print_string:
    push {lr}
    mov r1, r0 @ pointer to actual letter
    mov r2, #0 @ index of char

_print_loop: 
    ldrb r3, [r1, r2] @ r1, actual letter, r2 actual index
    cmp r3, #0
    beq _end_print
    add r2, r2, #1
    b _print_loop

_end_print:
    mov r7, #4 @ call to sys_write, more at https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#arm-32_bit_EABI
    mov r0, #1 @ because stdout = 1, more at https://man7.org/linux/man-pages/man3/stdin.3.html
    svc #0 @ execution of system call
    pop {pc} @ return to display_prompt


@ this whole process shows how to print "X ", if you go from the top to the bottom, that instructions gonna literally output "X " once, but if someone didnt stop, this thing gonna be execudet indefinitely