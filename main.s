.section .text
.global _start 
.extern display_prompt
.extern read_input

_start:
    bl main
    
main: 
    bl display_prompt
    bl read_input
    b main