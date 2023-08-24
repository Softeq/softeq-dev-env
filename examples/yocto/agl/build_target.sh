#!/bin/bash

cd build
source agl-init-build-env
bitbake agl-demo-platform
bitbake agl-demo-platform -c populate_sdk $@
