#!/usr/bin/bash

repo init -b guppy -m guppy_7.0.2.xml -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo
repo sync
source meta-agl/scripts/aglsetup.sh -m raspberrypi3-64 agl-demo agl-netboot agl-appfw-smack agl-sota
