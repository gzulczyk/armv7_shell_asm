# Mini ARMv7 Shell

This project builds a minimal shell in **ARMv7 Assembly** for **Linux**.  
It shows a prompt, reads input, forks, and runs commands via `execve`.  
No libs, just raw syscalls.

## Files
- **`main.s`** – controls loop: `display` → `read` → `execute`
- **`display.s`** – prints shell prompt via `sys_write`
- **`read.s`** – reads user input into buffer via `sys_read`
- **`execute.s`** – forks child, runs `execve`, and waits via `wait4`

## Useful resources
[ARM 32-bit EABI syscalls](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#arm-32_bit_EABI)
