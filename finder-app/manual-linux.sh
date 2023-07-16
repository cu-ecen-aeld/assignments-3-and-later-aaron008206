#!/bin/bash
# Script outline to install and build kernel.
# Original Author: Siddhant Jajoo.

set -e
set -u

OUTPUT_DIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
# for course instruction.
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
# for latest stable.
#KERNEL_VERSION=v6.1.34
#BUSYBOX_VERSION=1_36_1

APPDIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
SCRIPTS_DIR=$(pwd)

if [ $# -lt 1 ]
then
        echo "- default directory for output : ${OUTPUT_DIR}"
else
        OUTPUT_DIR=$1
        echo "- directory for output : ${OUTPUT_DIR}"
fi

#if [ ! -d ${OUTPUT_DIR} ]
#then
#	sudo rm -rf ${OUTPUt_DIR}
#        mkdir -p ${OUTPUT_DIR}
#fi

sudo rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}
cd ${OUTPUT_DIR}

if [ -d "${OUTPUT_DIR}/linux-stable" ]
then
        echo "- deleting ${OUTPUT_DIR}/linux-stable for starting over.."
        sudo rm -rf ${OUTPUT_DIR}/linux-stable
fi

echo "- cloning linux stable verseion ${KERNEL_VERSION} from git into ${OUTPUT_DIR}"
git config --global advice.detachedHead false
git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}

echo "- checking out kernel version : ${KERNEL_VERSION}"
cd linux-stable
git checkout ${KERNEL_VERSION}

echo "- kernel build starts..."
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j $(nproc)
#make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules dtbs

echo "- Adding the Image in output directory"
cp "${OUTPUT_DIR}/linux-stable/arch/${ARCH}/boot/Image" ${OUTPUT_DIR}

echo "- Creating the staging directory for the root file system"
mkdir -p ${OUTPUT_DIR}/rootfs
cd ${OUTPUT_DIR}/rootfs

# TODO: Create necessary base directories
mkdir -p bin dev etc home lib lib64 sys tmp usr/bin usr/lib usr/sbin var/log

cd "$OUTPUT_DIR"
if [ ! -d "${OUTPUT_DIR}/busybox" ]
then
    git clone git://busybox.net/busybox.git
    sudo chmod 766 ${OUTPUT_DIR}/busybox
    cd busybox
    git checkout ${BUSYBOX_VERSION}

    # TODO:  Configure busybox
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
else
    cd busybox
fi

# Make and install busybox
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j $(nproc)
make CONFIG_PREFIX=${OUTPUT_DIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install
echo -e "- change the ownership of /rootfs will be performed at the end of the process.\n"
echo -e "- busybox binary-file check."
file ./busybox

# Add library dependencies to rootfs
INTERPRETER=$(${CROSS_COMPILE}readelf -a ./busybox | grep "program interpreter" | cut -c 45- | tr -d ']')
LIBRARY=$(${CROSS_COMPILE}readelf -a ./busybox | grep "Shared library" | cut -d'[' -f2 | tr -d ']')
echo -e "\n- library dependencies.\n${INTERPRETER}\n${LIBRARY}\n"

SYSROOT=$(${CROSS_COMPILE}gcc -print-sysroot)
cp "$SYSROOT/lib/$INTERPRETER" "${OUTPUT_DIR}/rootfs/lib/"
for lib in $LIBRARY; do
        cp "$SYSROOT/lib64/$lib" "${OUTPUT_DIR}/rootfs/lib64/"
done

# Make device nodes
cd ${OUTPUT_DIR}/rootfs/dev
sudo mknod -m 666 null c 1 3
sudo mknod -m 666 console c 5 1

# Clean and build the writer utility if Makefile exists
echo -e "- app compilation."
cd ${APPDIR}
make clean
make CROSS_COMPILE=${CROSS_COMPILE}

# Copy the finder related scripts and executables to the /home directory on the target rootfs
cp writer finder.sh finder-test.sh autorun-qemu.sh ${OUTPUT_DIR}/rootfs/home/
cp -r conf/ ${OUTPUT_DIR}/rootfs/home/

# Chown the root directory
sudo chown -R root:root ${OUTPUT_DIR}/rootfs/

# Create initramfs.cpio.gz
echo -e "\n- creating initramfs.cpio.gz"
cd ${OUTPUT_DIR}/rootfs
find . | cpio -H newc -ov --owner root:root | gzip > ../initramfs.cpio.gz
cd ..

echo "- manual-linux.sh execution completed."
