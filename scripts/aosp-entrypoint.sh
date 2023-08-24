#!/bin/bash

set -e

echo -n "Creating /tmp/ccache and /aosp directory : " && \
    mkdir -p /tmp/ccache /aosp && \
    chown $DOCKER_USER:$DOCKER_GROUP /tmp/ccache /aosp && \
    echo "done"

# kvm is used for the android emulator
addgroup kvm 2>/dev/null || true

gpasswd -a $DOCKER_USER kvm
chown root:kvm /dev/kvm