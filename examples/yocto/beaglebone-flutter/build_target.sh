#!/bin/bash

source prepare_env.sh
bitbake -c clean core-image-weston
bitbake core-image-weston