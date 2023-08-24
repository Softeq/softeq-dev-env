#!/bin/bash

echo "!!!!!ATTENTION!!!!!! Make sure than you've added to ssh-agent your personal key to access to git@linode.boundarydevices.com"

repo init -u http://github.com/boundarydevices/boundary-bsp-platform -b zeus
repo sync -j4

EULA=1 MACHINE=nitrogen6x DISTRO=boundary-wayland . setup-environment build

