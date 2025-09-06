.section .data                  @ data section for variables and static data
prompt: .asciz "X "             @ declaration of ascii sign of our shell, i decied to make anothar than Ed from LLTV and i use X instead of dolar sign :) 

.section .text                  @ code section, place where instructions go
.global display_prompt          @ make function "display_prompt" globally available
.global print_string            @ make function "print_string" globally available

display_prompt: 
    push {lr}                   @ save the reference point of main function
    ldr r0, =prompt             @ load in r0 register start address of "X "
    bl print_string             @ branch to the print_string function
    pop {pc}                    @ return to the main func via using the lr saved in the beginning in that declared func

print_string:
    push {lr}                   @ save the link register value
    mov r1, r0                  @ pointer to address of declared string
    mov r2, #0                  @ index of char

_print_loop: 
    ldrb r3, [r1, r2]           @ load 1 byte from memory at address (r1 + r2) into r3
    cmp r3, #0                  @ check does r3 has null-terminator
    beq _end_print              @ if so, go to the `_end_print` function
    add r2, r2, #1              @ if not, add 1 to the r2 register, so index+1 
    b _print_loop               @ repeat loop

_end_print:
    mov r7, #4                  @ call to sys_write, 
    mov r0, #1                  @ because stdout = 1
    mov r1, r1                  @ r1 already points to string 
    mov r2, r2                  @ r2 already contains string length
    svc #0                      @ execution of system call
    pop {pc}                    @ return to display_prompt