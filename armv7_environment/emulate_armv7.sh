#!/bin/bash
set -e # Stop when one step doesn't finish properly

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
    mv initramfs-lts "${INITRD}"
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
  -append "console=ttyAMA0 autoinstall=cdrom:/preseed.txt" \
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
echo "################################################################################"
echo
echo "After installing Alpine to the disk, use './run.sh' to boot from disk."
echo
echo "################################################################################"
echo

sleep 5
./alpine-install.sh #try to boot installer with auto configuration file

