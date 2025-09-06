.section .data                  @ data section for variables and static data
.global buffer                  @ make `buffer` space globally available
.global path                    @ make `path` space globally available
.global argv                    @ make `argv` space globally available

prefix: .asciz "/bin/"          @ define prefix as ASCII string "/bin/" because that shell gonna support only programs from /bin/ folder
buffer: .space 256              @ define space for buffer, it's 256 bytes
path: .space 256                @ define space for path, it's 256 bytes
argv: .space 256                @ define space for argv's 

.section .text                  @ code section
.global fork_process            @ make function `fork_process` globally available
.extern concat_strings          @ use external function `concat_strings` which is shared between other files
.extern strip_newline           @ use external function `strip_newline` which is shared between other files
.extern not_found               @ use external function `not_found` which is shared between other files

fork_process:
    push {r7, lr}               @ save r7 register and link register value
    mov r7, #2                  @ set 2 inside r7 register (fork syscall)
    svc #0                      @ execute the syscall
    cmp r0, #0                  @ check fork return value (0 = child, >0 = parent, <0 = error)
    beq child_process           @ if so, go to `child_process` function
    bne parent_process          @ if not, go to `parent_process` function
    pop {r7, pc}                @ return back the r7 & pc value

child_process: 
    push {r7, lr}               @ save r7 and link register value
    ldr r0, =prefix             @ load beginning address of the `prefix` label
    ldr r1, =buffer             @ load beginning address of the `buffer` label
    ldr r2, =path               @ load beginning address of the `path` label
    ldr r3, =argv               @ load beginning address of the `argv` label
    bl concat_strings           @ go to `concat_strings` and save link register to go back and do next instruction inside this file
    ldr r0, =path               @ load `path` for execve 1st argument [filename]
    ldr r1, =argv               @ load `argv` for execve 2nd argument [argv]
    mov r2, #0                  @ set 0 into r2 register because there not using envp argument [envp]
    mov r7, #11                 @ syscall to execve
    svc #0                      @ execute syscall
    bl not_found                @ if child_process would be unable to execute declared program, go to the `not_found` section
    mov r7, #1                  @ set r7 value to exit syscall
    mov r0, #127              @ exit status 127 = command not found
    svc #0                      @ execute syscall

parent_process:
    mov r7, #0x72               @ syscall to sys_wait4 - syscall which waits for its child
    mov r0, #-1                 @ -1 -> wait for any child process 
    mov r1, #0                  @ status pointer = NULL (wait4 2nd argument)
    mov r2, #0                  @ no special flags for wait4 (3rd argument)
    svc #0                      @ execute
    pop {r7, pc}                @ return back the r7 and pc value


