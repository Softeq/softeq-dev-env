#!/bin/bash

echo "Flashing..."
sudo device/boundary/scripts/mksdcard.sh /dev/$1 nitrogen6x --force
