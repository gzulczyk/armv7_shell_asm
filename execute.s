.section .data
.global buffer
.global path
.global argv

prefix: .asciz "/bin/" 
buffer: .space 256 
path: .space 256  
argv: .space 256 @ reserve some space for command arguments like -l -a -la etc

.section .text
.global fork_process
.extern concat_strings
.extern strip_newline
.extern not_found

fork_process:
    push {r7, lr}
    mov r7, #2
    svc #0
    cmp r0, #0
    beq child_process
    bne parent_process
    pop {r7, pc}

child_process: 
    push {r7, lr}
    ldr r0, =prefix
    ldr r1, =buffer
    ldr r2, =path 
    ldr r3, =argv
    bl concat_strings
    ldr r0, =path
    ldr r1, =argv
    mov r2, #0
    mov r7, #11 @syscall to idk right now
    svc #0
    bl not_found
    mov r7, #1
    mov r0, #127 @syscall to exit if something goes wrong
    svc #0

parent_process:
    mov r7, #0x72 @ syscall to sys_wait4 
    mov r0, #-1 @ -1 -> wait for any child process 
    mov r1, #0 
    mov r2, #0 
    svc #0
    pop {r7, pc}


