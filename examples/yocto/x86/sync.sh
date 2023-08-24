#!/bin/bash

if [ "$1" == "state" ]; then
  [ -d "poky" ] && echo "ready" || echo "empty"
  exit 0
fi

git clone --single-branch --no-tags --depth 1 git://git.yoctoproject.org/poky

#It moves us to build dir
source prepare_env.sh

# Create .iso image by default (but only if image type is not already set in
# local.conf)

LOCAL_CONF="conf/local.conf"

if ! grep -q "IMAGE_FSTYPES" $LOCAL_CONF; then
    echo -e "\n#Generate .iso image" >> $LOCAL_CONF
    echo "IMAGE_FSTYPES = \"live\"" >> $LOCAL_CONF
fi
