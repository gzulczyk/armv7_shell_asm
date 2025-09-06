.section .text                  @ put the following code into the .text (code) section
.global read_input              @ export 'read_input' so it can be linked and called by other files
.extern buffer                  @ uses the buffer defined elsewhere in the program

read_input:
    push {r7, lr}               @ keep the r7 (syscall) register and link register (return address) to the stack, so they can be restored before returning
    ldr r1, =buffer             @ load into r1 register the buffer which was taken from external place (execute.s)
    mov r2, #255              @ set value 255 for the `read` syscall, declaration of the maximum number of bytes to read (not 256, because one extra byte gonna be used for null-terminator)
    mov r7, #3                  @ syscall number for sys_read on ARM
    mov r0, #0                  @ r0 will be used as fd=0 so its basically stdin
    svc #0                      @ executes syscall with provided arguments - read(0,buffer,255)
    add r1, r1, r0              @ advance r1 to buffer + bytes_read -> points to first free byte
    mov r2,#0                   @ prepare a 0x00 byte (C null terminator actually)
    strb r2, [r1]               @ write one extra byte (0x00 from r2) just past the last character -> null terminator
    pop {r7, pc}                @ restore r7 and return to caller (pc <- lr)

