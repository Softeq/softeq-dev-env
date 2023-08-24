#!/bin/bash

set -e

# This script designed to be used a docker ENTRYPOINT "workaround" missing docker
# feature discussed in docker/docker#7198, allow to have executable in the docker
# container manipulating files in the shared volume owned by the USER_ID:GROUP_ID.
#
# Reasonable defaults if no USER_ID/GROUP_ID environment variables are set.
if [ -z ${USER_ID+x} ]; then USER_ID=1000; fi
if [ -z ${GROUP_ID+x} ]; then GROUP_ID=1000; fi

echo -n "Creating user UID/GID [$USER_ID/$GROUP_ID] : " && \
    groupadd -g $GROUP_ID -r $DOCKER_GROUP && \
    useradd -u $USER_ID --create-home -r -g $DOCKER_GROUP $DOCKER_USER && \
    echo "done"

echo -n "Adding user $DOCKER_USER to group sudo : " && \
    adduser $DOCKER_USER sudo >/dev/null && \
    echo "done"

echo -n "Adding user $DOCKER_USER to group video : " && \
    adduser $DOCKER_USER video >/dev/null && \
    echo "done"

echo "$DOCKER_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

echo "$DOCKER_USER:$DOCKER_USER" | chpasswd

echo -n "Copying .gitconfig and .ssh/config to new user home : " && \
    cp /root/git_config /home/$DOCKER_USER/.gitconfig && \
    chown $DOCKER_USER:$DOCKER_GROUP  /home/$DOCKER_USER/.gitconfig && \
    mkdir -p /home/$DOCKER_USER/.ssh && \
    cp /root/ssh_config /home/$DOCKER_USER/.ssh/config && \
    chown $DOCKER_USER:$DOCKER_GROUP -R /home/$DOCKER_USER/.ssh && \
    echo "done"

# Execute command as user
export HOME=/home/$DOCKER_USER

for f in /start.d/* ; do
    [ -x $f ]  && [ ! -d $f ] && echo "Starting $f" && source $f
done

# Make dir for .pid file at /var/run/user/${USER_ID}
mkdir --parents --mode=777 /var/run/user/${USER_ID}

set +e
# Default to 'bash' if no arguments are provided
args="$@"
if [ $# -eq 0 ]; then
    echo "Enterring shell"
    exec sudo -E -u $DOCKER_USER -s
else
    echo "Performing ...'$args'"
    sudo -E -s -u $DOCKER_USER "$@"
fi
exit $?
