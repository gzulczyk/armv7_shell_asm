# Mini ARMv7 Shell

This project builds a minimal shell in **ARMv7 Assembly** for **Linux**.  
It shows a prompt, reads input, forks, and runs commands via `execve`.  
No libs, just raw syscalls.

## Files
- **`main.s`** – concatenates whole process of that mini-shell, displays prompt, read value, put value into execve and handles error and termination
- **`display.s`** – print the shell prompt via `sys_write`
- **`read.s`** – reads user input into `buffer` space via `sys_read`
- **`execute.s`** – forks child, builds full path and `argv[]`, runs `execve`, parent waits for `wait4` call
- **`concat.s`** - make declared string for concatenation via `strip_newline`, concatenate `path` with declared `buffer` value and creates full `argv[]` and return value to next instructions
- **`end.s`** - checks does `endShell` string was typed into mini-shell
- **`not_found.s`** - prints error if command not found

## Features
- Displays a custom prompt `X ` using `sys_write`
- Reads user input into a buffer with `sys_read`
- Strips the trailing newline and checks for the `endShell` string to terminate program 
- Concatnates `/bin/` with the typed command and builds an `argv[]` array (that mini-shell support only `/bin/` programs)
- Forks the process and executes the command in the child using `execve`
- Parent waits for the child process with `wait4` call
- Print an custom error message to `stderr` from `end.s` file if the command is not found

