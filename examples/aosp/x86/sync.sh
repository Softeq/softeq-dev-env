#!/bin/bash

repo init --repo-branch=repo-1 -u git://git.osdn.net/gitroot/android-x86/manifest -b oreo-x86 -m android-x86-8.1-r6.xml
repo sync --no-tags --no-clone-bundle -c -j$(nproc --all)
