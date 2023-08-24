#!/bin/bash
repo init -u https://github.com/Freescale/fsl-community-bsp-platform -b thud
repo sync

# first time yocto enviroment setup
MACHINE=imx6ullevk krammer=krammer-poky source setup-environment build
