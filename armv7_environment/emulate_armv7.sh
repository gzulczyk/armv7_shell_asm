#!/bin/bash
set -e 

ISO_MAIN="https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/armv7/alpine-standard-3.22.1-armv7.iso"
ISO_MIRROR="https://web.archive.org/web/20250823194237/https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/armv7/alpine-standard-3.22.1-armv7.iso"

ISO_FILE="alpine.iso"
ISO_MD5="0cba2a7ba4ce8c1c84fd626071ae6fe4"
    
DISK_IMAGE="alpine.qcow2"
KERNEL="vmlinuz"
INITRD="initrd.gz"

DISK_SIZE="2G"
QEMU_ARCH="${QEMU_ARCH:-}"

REQUIRED_CMDS=("wget" "md5" "7z" "mv" "cat" "chmod")

echo "Checking required tools..."
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: $cmd is not installed or not in PATH, try to install it via proper Package Manager in your OS!"
        exit 1
    fi
done

if [ -z "$QEMU_ARCH" ]; then
    if command -v qemu-system-arm > /dev/null 2>&1; then
        QEMU_ARCH="qemu-system-arm"
    elif command -v qemu-system-x86_64 > /dev/null 2>&1; then
        QEMU_ARCH="qemu-system-x86_64"
    else
        echo "QEMU is not installed, or you are using an undeclared QEMU architecture version. Please set the QEMU_ARCH variable manually to the correct one, and install QEMU if it is missing."
        exit 1
    fi 
fi
echo "QEMU is installed, continuing..." 

if [ ! -f "${ISO_FILE}" ]; then
    echo "Downloading Alpine ISO..."

    if curl --head --silent --fail "$ISO_MAIN" > /dev/null; then
        ISO_URL="$ISO_MAIN"
    else
        ISO_URL="$ISO_MIRROR"
    fi

    wget -O "${ISO_FILE}" "${ISO_URL}"
else
    echo "ISO already exists, skipping download."
fi

CALC_MD5=$(md5 -q "$ISO_FILE")

if [ "$CALC_MD5" != "$ISO_MD5" ]; then
    echo "Mismatch, MD5 of downloaded ISO doesn't match!"
    return false
else
    echo "MD5 is correct"
fi

if [ ! -f "${DISK_IMAGE}" ]; then
    echo "Creating disk image ${DISK_IMAGE}..."
    qemu-img create -f qcow2 "${DISK_IMAGE}" "${DISK_SIZE}"
else
    echo "Disk image already exists, skipping."
fi

if [ ! -f "${KERNEL}" ] || [ ! -f "${INITRD}" ]; then
    echo "Extracting kernel and initrd from ISO..."
    7z e alpine.iso boot/vmlinuz-lts* boot/initramfs-lts*
    mv vmlinuz-lts "${KERNEL}"
    mv initramfs-lts ${INITRD}
    mkdir initrd-tmp
    mv ${INITRD} ./initrd-tmp/${INITRD}

    echo "Unpacking initramfs..."
    
    cd initrd-tmp
    gzip -dc "./${INITRD}" | cpio -idmv
    
    echo "Modyfing the init file..."
    head -n $((1095 - 1)) "init" > "init.modded"

    cat >> "init.modded" <<'EOF'
# ==== Inject answerfile into sysroot ====
ANSWERFILE="$sysroot/etc/answerfile"

cat >"$ANSWERFILE" <<'EOF_ANSWERFILE'
KEYMAPOPTS=none
HOSTNAMEOPTS=alpine
DEVDOPTS=mdev
INTERFACESOPTS="auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
hostname alpine-test
"
TIMEZONEOPTS=none
PROXYOPTS=none
APKREPOSOPTS="http://dl-cdn.alpinelinux.org/alpine/v3.22/main
http://dl-cdn.alpinelinux.org/alpine/v3.22/community"
USEROPTS="-a -u -g audio,input,video,netdev juser"
SSHDOPTS=openssh
NTPOPTS=none
DISKOPTS="-m sys /dev/vdb"
KERNELOPTS="-k virt"
LBUOPTS=none
APKCACHEOPTS=none
EOF_ANSWERFILE
echo ">>> Injected automated setup answerfile into sysroot"

# ==== Create wrapper that runs setup-alpine and then init ====
cat > "$sysroot/sbin/firstboot.sh" <<"EOS"
#!/bin/sh



echo ">>> Bringing up static network (QEMU usernet)"
ip addr add 10.0.2.15/24 dev eth0
ip link set eth0 up
ip route add default via 10.0.2.2
echo "nameserver 1.1.1.1" > /etc/resolv.conf

echo ">>> Running automated Alpine setup"
/usr/sbin/setup-alpine -f /etc/answerfile || {
echo ">>> setup-alpine failed, dropping to shell"
poweroff
}
echo ">>> Setup finished, shutting down in 5s..."
sleep 5
exec poweroff -f
EOS
chmod +x "$sysroot/sbin/firstboot.sh"

# ==== Install post-install script into the *new* Alpine root ====
cat > "$sysroot/etc/local.d/armv7asm.start" <<"EOS"
#!/bin/sh
set -eu
SCRIPT="/etc/local.d/armv7asm.start"

# --- Network setup (only if not already configured) ---
if ! ip addr show dev eth0 | grep -q "10.0.2.15/24"; then
    ip addr add 10.0.2.15/24 dev eth0 || true
    ip link set eth0 up || true
    ip route add default via 10.0.2.2 2>/dev/null || true
fi

# Only add resolver if it doesn't already exist
grep -q "1.1.1.1" /etc/resolv.conf 2>/dev/null || echo "nameserver 1.1.1.1" > /etc/resolv.conf

# --- Package install (idempotent) ---
apk update || true
apk add --no-cache git make binutils

# --- Git clone (safe re-run) ---
if [ ! -d /root/.git ]; then
    git clone https://github.com/gzulczyk/armv7_shell_asm.git /root
else
    echo "Repository already exists, pulling latest changes..."
    git -C /root pull --ff-only || true
fi

# --- Build ---
cd /root
make || { echo "Build failed, check logs"; exit 1; }

# --- Self-destruct if successful ---
echo ">>> armv7asm.start completed successfully, cleaning up..."
rm -f "$SCRIPT"

# If no other local.d scripts remain, disable local service
if [ -z "$(ls -A /etc/local.d 2>/dev/null)" ]; then
    rc-update del local default || true
fi

EOS

chmod +x "$sysroot/etc/local.d/armv7asm.start"

# enable the local service inside the target system
chroot "$sysroot" rc-update add local default


# ==== fix setup-disk to support armv7 bootloader ====
if [ -f "$sysroot/usr/sbin/setup-disk" ]; then
    echo ">>> Patching setup-disk inside sysroot (disable u-boot default)"
    sed -i 's/arm\*|aarch64) : ${BOOTLOADER:=u-.*/arm*|aarch64) : ${BOOTLOADER:=none};;/' \
        "$sysroot/usr/sbin/setup-disk"
fi

# ==== change default setup-disk option for auto-format (it's isolated enviroment so be calm ;)  ====
if [ -f "$sysroot/usr/sbin/setup-disk" ]; then
    echo ">>> Patching setup-disk inside sysroot to change default ask_yesno from 'n' to 'y'"
    sed -i \
    's/ask_yesno "WARNING: Erase the above disk(s) and continue? (y\/n)" n/ask_yesno "WARNING: Erase the above disk(s) and continue? (y\/n)" y/' \
        "$sysroot/usr/sbin/setup-disk"
fi

# ==== Replace switch_root target ====
exec switch_root $switch_root_opts $sysroot /sbin/firstboot.sh
[ "$KOPT_splash" != "no" ] && echo exit > /sysroot/$splashfile
echo "initramfs emergency recovery shell launched"
exec /bin/busybox sh
reboot
EOF

    # Atomic replace
    rm init
    mv "init.modded" "init"
    chmod +x ./init
    echo "Init file patched successfully."

    echo "Repacking initramfs..."
    find . | cpio -o -H newc | gzip -9 > "../${INITRD}"
    cd ..
    echo "Patched initrd ready at ${INITRD}"
   else
    echo "vmlinuz & initrd already extracted."
fi

cat > alpine-install.sh <<EOF
#!/usr/bin/env bash
${QEMU_ARCH} \
  -M virt \
  -cpu cortex-a15 \
  -m 1024 \
  -kernel ${KERNEL} \
  -initrd ${INITRD} \
  -append "console=ttyAMA0" \
  -drive file=${DISK_IMAGE},if=none,format=qcow2,id=hd0 \
  -device virtio-blk-device,drive=hd0 \
  -drive file=${ISO_FILE},if=none,format=raw,id=cdrom \
  -device virtio-blk-device,drive=cdrom \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device virtio-net-device,netdev=net0 \
  -nographic
EOF
chmod +x alpine-install.sh

cat > run.sh <<EOF
#!/usr/bin/env bash
${QEMU_ARCH} \\
  -M virt \\
  -cpu cortex-a15 \\
  -m 1024 \\
  -kernel ${KERNEL} \\
  -initrd ${INITRD} \\
  -append "console=ttyAMA0 root=/dev/vda3 rootfstype=ext4 rw" \\
  -drive file=${DISK_IMAGE},if=none,format=qcow2,id=hd0 \\
  -device virtio-blk-device,drive=hd0 \\
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \\
  -device virtio-net-device,netdev=net0 \\
  -nographic
EOF
chmod +x run.sh

echo
echo "################################################################################"
echo
echo "Basic configuration complete, right now, we're trying to install OS via qemu..."
echo
echo "################################################################################"
echo
sleep 5
./alpine-install.sh 
sleep 5
echo "################################################################################"
echo
echo "Installation of alpine-linux complete, trying for the first run via ./run.sh script..."
echo
echo "################################################################################"
echo
./run.sh
