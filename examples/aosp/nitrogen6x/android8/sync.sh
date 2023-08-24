#!/bin/bash

echo "!!!!!ATTENTION!!!!!! Make sure than you've added to ssh-agent your personal key to access to git@linode.boundarydevices.com. See README.md"

repo init -u git://github.com/boundarydevices/android-manifest.git -b boundary-imx-o8.0.0_1.0.0-ga --depth 1
repo sync --network-only --jobs=1 --current-branch --no-tags
repo sync --detach --local-only --jobs=1 --current-branch --no-tags
