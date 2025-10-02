# ARMv7 Environment to Test

This subfolder of the **armv7_shell_asm** project provides an emulated 32-bit ARMv7 environment with a dedicated Linux OS, so you can test the project in a “native” setup.

## Files

- **`emulate_armv7.sh`** – script that automatically downloads the required components (QEMU, Alpine ARMv7 image, etc.), prepares the QEMU configuration, and modifies it as needed instead of directly booting the OS.

### Files created or used by `emulate_armv7.sh`

- **`vmlinuz` & `initrd.gz`** – kernel and initramfs required to boot the OS  
- **`alpine.iso`** – Alpine ARMv7 ISO image  
- **`alpine.qcow2`** – virtual disk image for persistent storage  
- **`init`** – a modified init script that automates the entire installation process; it is eventually included in the spoofed `initrd.gz` when `emulate_armv7.sh` makes its magic ;) 


## Installation Process

1. Run `./emulate_armv7.sh`  
   - (If the installation doesn’t complete automatically, you can run `./alpine-install.sh` after the first execution of `emulate_armv7.sh`.)  

2. Go through the installation process.  
   - A modified `setup-disk` is included, so you can basically just press Enter through everything.  
   - (You may still set your own root password if you wish.)  

3. After installation, start the VM with `./run.sh`.  
   - The first run may take some time because it downloads the ARMv7 script files from the repo.  

4. Log in to Alpine.  
   - If you didn’t set a password, just type `root` as the username and press Enter at the password prompt.  

5. Run `./shell`.  

6. Have fun!
