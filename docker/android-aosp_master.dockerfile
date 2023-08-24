# Based on official AOSP documentation https://source.android.com/setup/build/initializing

# Official guide says master is supported in ubuntu:18.04
FROM ubuntu:18.04

# Basic development / buildsystem packets from official doc
RUN apt-get update && \
    apt-get install -y git-core gnupg flex bison build-essential zip curl \
    zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 libncurses5 \
    lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev \
    libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig rsync

# vim is optional for hacks in container
RUN apt-get install -y sudo vim

# python3 is required for successfull 'repo' execution
RUN apt-get install -y python3

# 'repo' will use /usr/bin/python assuming it is python3
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 0

# Install 'repo' to manage android repositories
RUN export REPO=$(mktemp /tmp/repo.XXXXXXXXX) && ls -la $REPO && \
    curl -o ${REPO} https://storage.googleapis.com/git-repo-downloads/repo && \
    gpg --keyserver keys.openpgp.org --recv-key 8BB9AD793E8E6153AF0F9A4416530D5E920F5C65 && \
    curl -s https://storage.googleapis.com/git-repo-downloads/repo.asc | gpg --verify - ${REPO} && \
    install -m 755 ${REPO} /usr/local/bin/repo

# git_config holds "Fake User" identity. With it 'repo' will fetch ASOP git repositories
COPY docker/git_config /root/git_config
# ssh_config disables strict host key check
COPY docker/no_strict_ssh_config /root/ssh_config

# /aosp would hold the main AOSP working directory with .repo and AOSP sources inside
VOLUME ["/aosp"]
WORKDIR /aosp

ENV DOCKER_USER aosp
ENV DOCKER_GROUP aosp

RUN mkdir -p /start.d

COPY scripts/aosp-entrypoint.sh /start.d/001-aosp-builder.sh
RUN chmod 755 /start.d/001-aosp-builder.sh

# docker_entrypoint.sh will run each time container starts from this image.
# - creates user 'aosp' with same uid as the current user (who called docker run)
# - creates group 'aosp' with same gid as of the current user (who called docker run)
# - copies to ssh_config/git_config to home directory of user 'aosp'
# - creates /aosp directory
# - sets password 'aosp' for user 'aosp'
# - execs bash or any other startup command on behalf of user 'aosp'
COPY scripts/common-entrypoint.sh /root/docker-entrypoint.sh
# Make it runnable
RUN chmod 755 /root/docker-entrypoint.sh
ENTRYPOINT ["/root/docker-entrypoint.sh"]
