# Instructions cheatsheet

**Data Movement**
* `ldr Rd, =label` - load address of label into register
* `ldr Rd, [Rn]` - load word from the memory at address in `Rn` into `Rd` register
* `ldr Rd, [Rn], #imm` - load word from `Rn`, then post-increment `Rn` by `imm`

* `ldrb Rd, [Rn]` - load byte from memory at address `Rn` into register
* `ldrb Rd, [Rn], #imm` - load byte from memory at address `Rn` into register and then post-increment `Rn` by `imm`

* `str Rd, [Rn]` - store word from register `Rd` into memory at `Rn` address
* `str Rd, [Rn], #imm` - store word, then post-increment `Rn` by `imm`

* `strb Rd, [Rn]` - store byte from `Rd` to `Rn` register address (save value from `Rd` into pointed address from `Rn`)
* `strb Rd, [Rn, #-imm]` - store byte at `[Rn - imm]` offset 

* `mov Rd, Rs` - copy register `Rs` into `Rd`
* `mov Rd, #imm` - set `imm` value inside `Rd`

**Arithmetic/Logic**
* `add Rd, Rn, #imm` - add `imm` with `Rn` and set the value inside `Rd`
* `sub Rd, Rn, #imm`- substract `imm` from `Rd` and set value into `Rd`
* `subs Rd, Rn, #imm` - subtract imm from Rn, store result in Rd, and update NZCV flags (like doing sub + cmp in one instruction, so you can immediately branch)


**Comparison/Branching**
* `cmp Rn, #imm` - compare `Rn` with `imm` (set proper flag NZCV)
* `cmp Rn, Rm` - compare register with register 
* `beq label` - branch if equal (Z=1)
* `bne label` - branch if not equal (Z=0)
* `b label` - branch with no condition
* `bl label` - branch with link (call function and save return link register `lr`)

**Stack/Procedure**
* `push {regs}` - save registers onto stack (on the top of memory frame)
* `pop {regs}` - restore registers from stack 
* `pop {pc}` - return from function (restore pc, commonly used when you branch function and want return to the main one)

**Syscalls**
* `svc #0` - make system call (use r7 register to execute proper syscall and use proper arguments into r0, r1 etc)

