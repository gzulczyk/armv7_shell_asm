.section .text
.global _start 
.extern display_prompt
.extern read_input
.extern fork_process 
.extern strip_newline
.extern check_terminate
.extern buffer
.extern not_found

_start:
    bl main

main: 
    bl display_prompt
    bl read_input
    ldr r0, =buffer
    bl strip_newline
    bl check_terminate
    bl fork_process
    b main
