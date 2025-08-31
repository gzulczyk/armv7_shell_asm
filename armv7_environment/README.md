# ARMv7 environment to test it

This subfolder of the **armv7_shell_asm** project provides an emulated 32-bit ARMv7 environment with a dedicated Linux OS so you can test the project in a “native” setup.

## Files
- **`run.sh`** – script that automatically downloads the required components (QEMU, Alpine ARMv7 image, etc.), creates the proper QEMU configuration, and modifies it as needed instead of directly booting the OS.

### Files created or used by run.sh
- **`vmlinuz/initrgd.z`** – unnecessary files to boot OS
- **`alpine.iso`** – the iso of alpine armvv7 os
- **`armv7.qcow2`** – the virtual disk space
