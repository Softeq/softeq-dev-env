#!/bin/bash

set -e

if [ -d /workdir/.cmake_registry ]; then
    ln -s /workdir/.cmake_registry /home/$DOCKER_USER/.cmake
    chown -h $DOCKER_USER:$DOCKER_USER /home/$DOCKER_USER/.cmake
fi

echo "Start DBUS system & session daemon services"
export DBUS_SYSTEM_BUS_ADDRESS=`dbus-daemon --fork --system --print-address`
export DBUS_SESSION_BUS_ADDRESS=`sudo -E -u $DOCKER_USER dbus-daemon --fork --session --print-address`

