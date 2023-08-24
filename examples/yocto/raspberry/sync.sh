#!/bin/bash

set -e

MANIFEST_DIR="tmp_manifest_dir"
MNIFEST_FILE="manifest.xml"

if [ ! -d ".repo" ]; then
    rm -rf $MANIFEST_DIR  > /dev/null 2>&1
    mkdir $MANIFEST_DIR
    cp $MNIFEST_FILE ./$MANIFEST_DIR

    pushd $MANIFEST_DIR
    git init
    git add $MNIFEST_FILE
    git commit --author="test name <test@name.com>" -m "Commit for git repo tool"
    popd
    # If you want the repo to be whit full depth remove --depth=1
    repo init -u $MANIFEST_DIR -m $MNIFEST_FILE  --depth=1

    rm -rf $MANIFEST_DIR  > /dev/null 2>&1
fi

repo sync -j4

# Clean up the configuration if it exists
rm -rf build/conf > /dev/null 2>&1

source prepare_env.sh

LOCAL_CONF="conf/local.conf"
IMAGE_TYPE="tar.xz ext3 rpi-sdimg"

# Please set according to your model, see full list of supported machines at
# https://meta-raspberrypi.readthedocs.io/en/latest/layer-contents.html#supported-machines
MACHINE="raspberrypi3"

sed -e "s,MACHINE ??=.*,MACHINE ??= '$MACHINE',g" \
    -i $LOCAL_CONF

if ! grep -q "IMAGE_FSTYPES" $LOCAL_CONF; then
    echo -e "\n#Generate SD card image" >> $LOCAL_CONF
    echo "IMAGE_FSTYPES = '$IMAGE_TYPE'" >> $LOCAL_CONF
fi

echo 'DISTRO_FEATURES_remove=" x11 wayland vulkan pulseaudio 3g nfc sysvinit zeroconf"' >> $LOCAL_CONF
echo 'DISTRO_FEATURES_append=" systemd"' >> $LOCAL_CONF
echo 'VIRTUAL-RUNTIME_init_manager = "systemd"'  >> $LOCAL_CONF
echo 'DISTRO_FEATURES_BACKFILL_CONSIDERED += "sysvinit"' >> $LOCAL_CONF
echo 'IMAGE_FEATURES_remove = "splash"' >> $LOCAL_CONF
echo 'CMDLINE_append += "quiet"' >> $LOCAL_CONF

bitbake-layers add-layer \
 ../sources/meta-raspberrypi \
 ../sources/meta-openembedded/meta-oe
 