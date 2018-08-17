#!/bin/bash

set -e
set -o xtrace

SDCARD=/dev/mmcblk0

sudo dd if=/dev/zero of=${SDCARD} bs=1M count=8

echo -e "o\nn\np\n1\n\n\nw" | sudo fdisk ${SDCARD}

sudo mkfs.ext4 -O ^metadata_csum,^64bit ${SDCARD}p1

mkdir ./mnt

sudo mount ${SDCARD}p1 ./mnt

wget http://archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz

sudo bsdtar -xpf ArchLinuxARM-armv7-latest.tar.gz -C ./mnt/

sudo mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "NanoPi Neo boot script" -d boot.cmd ./mnt/boot/boot.scr

sudo umount ./mnt

git clone git://git.denx.de/u-boot.git
cd u-boot
git checkout tags/v2018.07
make -j4 ARCH=arm CROSS_COMPILE=arm-none-eabi- nanopi_neo_air_defconfig
make -j4 ARCH=arm CROSS_COMPILE=arm-none-eabi-

sudo dd if=u-boot-sunxi-with-spl.bin of=${SDCARD} bs=1024 seek=8

cd ..

sync

rm -rf ArchLinuxARM-armv7-latest.tar.gz
rm -rf u-boot
sudo rm -rf mnt
