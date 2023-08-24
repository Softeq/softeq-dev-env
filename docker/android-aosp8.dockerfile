#
# Minimum Docker image to build Android AOSP
#
FROM ubuntu:16.04

# /bin/sh points to Dash by default, reconfigure to use bash until Android
# build becomes POSIX compliant
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
    dpkg-reconfigure -p critical dash

RUN apt-get update && \
    apt-get install -y software-properties-common python-software-properties

RUN add-apt-repository ppa:openjdk-r/ppa

RUN apt-get install -y bc bison bsdmainutils build-essential curl vim symlinks \
    flex g++-multilib gcc-multilib git gnupg gperf lib32ncurses5-dev \
    lib32z1-dev libesd0-dev libncurses5-dev libssl-dev \
    libsdl1.2-dev libwxgtk3.0-dev libxml2-utils lzop sudo \
    openjdk-8-jdk \
    pngcrush schedtool xsltproc zip zlib1g-dev graphviz openssh-server mkisofs u-boot-tools \
    # missing packages for building oreo-x86
    python-mako python-enum34 gettext dosfstools mtools

RUN apt-get install -y qemu-system-i386

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://commondatastorage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
RUN chmod 755 /usr/local/bin/*

# Security hack for jack server
COPY docker/java.security /etc/java-8-openjdk/security/

# Install latest version of JDK
# See http://source.android.com/source/initializing.html#setting-up-a-linux-build-environment
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

# Android emulator setup
# add directory and setup android sdk and other tools for emulator
RUN mkdir emulator \
    && wget http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz -P /emulator/  --progress=bar:force:noscroll \
    && tar -xf /emulator/android-sdk_r24.4.1-linux.tgz  --directory /emulator/ > /dev/null\
    && rm  /emulator/android-sdk_r24.4.1-linux.tgz \
    && echo y | /emulator/android-sdk-linux/tools/android update sdk -u -a -t 52 > /dev/null \
    && echo y | /emulator/android-sdk-linux/tools/android update sdk -u -a -t 2 > /dev/null\
    && echo y | /emulator/android-sdk-linux/tools/android update sdk -u -a -t 1 > /dev/null\
    && echo y | /emulator/android-sdk-linux/tools/bin/sdkmanager "cmdline-tools;8.0" > /dev/null\
    && /emulator/android-sdk-linux/cmdline-tools/8.0/bin/sdkmanager --install "system-images;android-29;google_apis;x86_64"

COPY scripts/aosp-entrypoint.sh /start.d/001-aosp-builder.sh
RUN chmod 755 /start.d/001-aosp-builder.sh

COPY scripts/common-entrypoint.sh /root/docker-entrypoint.sh
RUN chmod 755 /root/docker-entrypoint.sh
ENTRYPOINT ["/root/docker-entrypoint.sh"]