#!/bin/sh
INPUT=$1
FILENAME=$2
SIZE=$3
dd if=/dev/zero of=$FILENAME bs=1M count=$SIZE
mkfs.ext4 $FILENAME
mkdir -p data
sudo mount -o loop $FILENAME data
sudo tar -xvf $INPUT -C data
sudo sync
sudo umount data
rmdir data
