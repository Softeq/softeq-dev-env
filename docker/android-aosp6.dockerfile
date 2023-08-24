#
# Minimum Docker image to build Android AOSP
#
FROM ubuntu:14.04

# /bin/sh points to Dash by default, reconfigure to use bash until Android
# build becomes POSIX compliant
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
    dpkg-reconfigure -p critical dash

# Keep the dependency list as short as reasonable
RUN apt-get update && \
    apt-get install -y \
        openjdk-7-jdk git-core zip zlib1g-dev libc6-dev-i386 \
        x11proto-core-dev libx11-dev lib32z-dev ccache \
        libgl1-mesa-dri libgl1-mesa-dev unzip bc bison bsdmainutils build-essential curl \
        flex g++-multilib gcc-multilib git gnupg gperf lib32ncurses5-dev \
        lib32readline-gplv2-dev lib32z1-dev libesd0-dev libncurses5-dev \
        libsdl1.2-dev libwxgtk2.8-dev libxml2-utils lzop \
        openjdk-7-jdk u-boot-tools \
        pngcrush schedtool xsltproc
RUN apt-get update && \
    apt-get install -y \
        android-tools-adb android-tools-fastboot \
        qemu-system-arm
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://commondatastorage.googleapis.com/git-repo-downloads/repo-1 /usr/local/bin/repo
RUN chmod 755 /usr/local/bin/*

WORKDIR /tmp

# All builds will be done by user aosp
COPY docker/git_config /root/git_config
COPY docker/no_strict_ssh_config /root/ssh_config
# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/tmp/ccache", "/aosp"]

# Work in the build directory, repo is expected to be init'd here
WORKDIR /aosp

ENV DOCKER_USER aosp
ENV DOCKER_GROUP aosp

RUN mkdir -p /start.d

COPY scripts/aosp-entrypoint.sh /start.d/001-aosp-builder.sh
RUN chmod 755 /start.d/001-aosp-builder.sh

COPY scripts/common-entrypoint.sh /root/docker-entrypoint.sh
RUN chmod 755 /root/docker-entrypoint.sh
ENTRYPOINT ["/root/docker-entrypoint.sh"]