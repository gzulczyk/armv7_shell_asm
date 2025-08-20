.section text @ we want execute that code, so we have to use the text section, not data, etc
.global _start @ declaration of program start point

prompt: .asciz "X " @ declaration of ascii sign of our shell, i decied to make anothar than Ed from LLTV and i use X instead of dolar sign :) 

_start:
    bl main @ switch to the main function, _start is the start point of whole program

main:
    bl display_prompt @ switch to display_prompt function
    b main            @ switch again to the begining of main

display_prompt: 
    push {lr} @ save the point of main func
    ldr r0, =prompt  @ load in r0 register address of "X "
    bl print_string @ switch to the print_string function
    pop {pc} @ go back to the main func via using the lr saved in the beginning in that declared func

print_string:
