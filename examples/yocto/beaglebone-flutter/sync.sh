#!/bin/bash

set -e

if [ "$1" == "state" ]; then

    is_sources_ready=true
    for source_dir in \
        "./sources/poky" \
        "./sources/meta-arm" \
        "./sources/meta-ti" \
        "./sources/meta-openembedded" \
        "./sources/meta-clang" \
        "./sources/meta-flutter" \
        "./sources/meta-arago" \
        "./sources/meta-qt5" \
        "./sources/meta-python" \
        "./sources/meta-beaglebone-flutter"
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

# https://github.com/meta-flutter/meta-flutter/issues/204
if [ ! -f ./sources/meta-flutter/classes/flutter-app.bbclass.orig ]; then
    patch -u -b ./sources/meta-flutter/classes/flutter-app.bbclass -i ./patch/flutter-app.bbclass.patch
fi

# Clean up the configuration if it exists
rm -rf build/conf > /dev/null 2>&1

source prepare_env.sh

LOCAL_CONF="conf/local.conf"
MACHINE="beaglebone-yocto"

sed -e "s,MACHINE ??=.*,MACHINE ??= '$MACHINE',g" -i $LOCAL_CONF

if ! grep -q "IMAGE_FSTYPES" $LOCAL_CONF; then
    echo -e "\n#Generate SD card image" >> $LOCAL_CONF
    echo "IMAGE_FSTYPES = '$IMAGE_TYPE'" >> $LOCAL_CONF
fi

echo 'DISTRO_FEATURES_remove = "x11"' >> $LOCAL_CONF
echo 'DISTRO_FEATURES_append = " wayland opengl"' >> $LOCAL_CONF

echo 'FLUTTER_RUNTIME = "release"' >> $LOCAL_CONF
echo 'FLUTTER_SDK_TAG = "3.3.8"' >> $LOCAL_CONF
echo 'IMAGE_INSTALL_append = " flutter-wayland-client"' >> $LOCAL_CONF
echo 'IMAGE_INSTALL_append = " flutter-gallery"' >> $LOCAL_CONF
echo 'IMAGE_INSTALL_append = " flutter-test-animated-background"' >> $LOCAL_CONF

bitbake-layers add-layer \
    ../sources/meta-arm/meta-arm \
    ../sources/meta-arm/meta-arm-toolchain \
    ../sources/meta-ti \
    ../sources/meta-openembedded/meta-oe \
    ../sources/meta-clang \
    ../sources/meta-flutter \
    ../sources/meta-arago/meta-arago-distro \
    ../sources/meta-arago/meta-arago-extras \
    ../sources/meta-qt5 \
    ../sources/meta-openembedded/meta-networking \
    ../sources/meta-openembedded/meta-python \
    ../sources/meta-beaglebone-flutter \
