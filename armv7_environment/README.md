# ARMv7 Environment to Test

This subfolder of the armv7_shell_asm project provides an emulated 32-bit ARMv7 environment with its very own Linux OS — so you can test the project in a “native” setup without hunting for an old Raspberry Pi.

## Files

- **`emulate_armv7.sh`** – a magical script that automatically downloads the required OS image (Alpine ARMv7), preps the QEMU config, tweaks it, and then pretends to boot the OS. Basically, it’s doing all the boring stuff for you.

### Files created or used by `emulate_armv7.sh`

- **`vmlinuz` & `initrd.gz`** – kernel and initramfs required to boot the OS  
- **`alpine.iso`** – Alpine ARMv7 ISO image  
- **`alpine.qcow2`** – virtual disk image for persistent storage  

## Installation Process

1. Run `./emulate_armv7.sh`  
   - (If the installation doesn’t complete automatically, you can run `./alpine-install.sh` after the first execution of `emulate_armv7.sh`.)  

2. Wait until alpine login shows up!

## Visual process
If you’re too busy (or just impatient), you can watch the whole installation process here:
https://www.youtube.com/watch?v=R-ZNrZvDgpE

(Pro tip: turn on playback speed 2x or even 4x — I won’t judge xD)

## Info 
Honestly, this entire thing is kinda pointless — I just wanted to prove to myself that I could do it. The whole ASM setup doesn’t really do much; it’s just proof that I can make weirdly niche stuff.

At some point, I thought about porting it to PowerShell, but my 2025 IT language goals already include Verilog, Haskell, Coq, and PyTorch and so yeah, no time. I definitely spent way too many nights automating the first installation for no real reason… but hey, it was fun until it wasn’t :D 

I guess I just wanted to prove I can mess with Alpine Linux internals because I've used to do similiar things with MS Windows at work. 

## Why I Didn’t Use a Cross-Compiler

So… you might ask, “Why didn’t you just use a cross-compiler like a normal person?”
Well, here’s the deal: I was working on a MacBook with an M1 Pro chip, which is ARM64 and every time I tried setting up a cross-compiler for ARM32, it turned into a full-on bug festival so I rejected this idea. 

Instead of battling mysterious errors, I decided to embrace chaos and build an emulated ARMv7 shell environment instead.

Was it overkill? Absolutely.
Was it fun? Also yes. 😎