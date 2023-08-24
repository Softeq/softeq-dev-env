#!/bin/bash

set -e

if [ "$1" == "state" ]; then

    is_sources_ready=true
    for source_dir in \
        "./sources/poky" \
        "./sources/meta-arm" \
        "./sources/meta-ti" \
        "./sources/meta-openembedded"
    do
        if [ ! -d "$source_dir" ]; then
            is_sources_ready=false
            break
        fi
    done

    [ "$is_sources_ready" = true ] && echo "ready" || echo "empty"
    exit 0
fi

MANIFEST_DIR="local_repo_manifest_dir"
MANIFEST_FILE="default.xml"

if [ ! -d ".repo" ]; then
    rm -rf $MANIFEST_DIR  > /dev/null 2>&1
    mkdir $MANIFEST_DIR
    cp $MANIFEST_FILE ./$MANIFEST_DIR

    pushd $MANIFEST_DIR
    git init
    git add $MANIFEST_FILE
    git commit -m "Local repo manifest"
    popd
    # If you want the repo to be whith full depth remove --depth=1
    repo init -u $MANIFEST_DIR -m $MANIFEST_FILE  --depth=1
    rm -rf $MANIFEST_DIR  > /dev/null 2>&1
fi

repo sync

# Clean up the configuration if it exists
rm -rf build/conf > /dev/null 2>&1

source prepare_env.sh

LOCAL_CONF="conf/local.conf"
MACHINE="beaglebone"

sed -e "s,MACHINE ??=.*,MACHINE ??= '$MACHINE',g" -i $LOCAL_CONF

bitbake-layers add-layer \
 ../sources/meta-arm/meta-arm \
 ../sources/meta-arm/meta-arm-toolchain \
 ../sources/meta-ti \
 ../sources/meta-openembedded/meta-oe \