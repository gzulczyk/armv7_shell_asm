.section text @ we want execute that code, so we have to use the text section, not data, etc
.global _start @ declaration of program start point

prompt: .asciz "X " @ declaration of ascii sign of our shell, i decied to make anothar than Ed from LLTV and i use X instead of dolar sign :) 

_start:
    bl main @ switch to the main function, _start is the start point of whole program

main:
    bl display_prompt @ switch to display_prompt function
    b main            @ switch again to the begining of main

display_prompt: 
    push { lr }
    ldr r0, =prompt 
    bl print_string