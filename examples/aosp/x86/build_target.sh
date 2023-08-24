#!/bin/bash

source prepare_env.sh
m -j4 iso_img KERNEL_DIR=kernel-4.9 2>&1 | tee build.out
