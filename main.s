.section .text                  @ code section
.global _start                  @ in that context, start point of main.s file
.extern display_prompt          @ uses the `display_prompt` defined elsewhere in the program 
.extern read_input              @ uses the `read_input` defined elsewhere in the program
.extern fork_process            @ uses the `fork_process` defined elsewhere in the program
.extern strip_newline           @ uses the `strip_newline` defined elsewhere in the program 
.extern check_terminate         @ uses the `check_terminate` defined elsewhere in the program
.extern buffer                  @ uses buffer defined elsewhere in the program

_start:
    bl main                     @ go to the main function

main: 
    bl display_prompt           @ go to the `display_prompt` function
    bl read_input               @ go to the `read_input` function
    ldr r0, =buffer             @ load the address of the first byte of buffer into r0
    bl strip_newline            @ go to the `strip_newline` function and use buffer from r0 register to strip it
    bl check_terminate          @ go to the `check_terminate` function and use stripped r0 register to check termination (check does it have special 'endShell' string to exit the whole program)
    cmp r0, #1                  @ check does check_terminate return 1
    beq exit_shell              @ if so, "endShell" found, go to `exit_shell` and terminate the program
    bl fork_process             @ if not, go to the "fork_process" and try to execute the program
    b main                      @ return back and go through the whole process again

exit_shell:
    mov r7, #1                  @ set syscall to exit
    mov r0, #0                  @ set 0 as error code (necessary for that call)
    svc #0                      @ execute it
