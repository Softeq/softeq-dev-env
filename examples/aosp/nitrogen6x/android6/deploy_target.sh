#!/bin/bash

echo "Preparing files..."

if ! cmp -s device/boundary/mkimage.sh patch_target/mkimage.sh
then patch device/boundary/mkimage.sh < patch_target/mkimage.patch
fi

if ! cmp -s device/boundary/mksdcard.sh patch_target/mksdcard.sh
then patch device/boundary/mksdcard.sh < patch_target/mksdcard.patch
fi

echo "Flashing..."
sudo device/boundary/mksdcard.sh /dev/$1 nitrogen6x --force
