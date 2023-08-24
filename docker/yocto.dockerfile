#
# Docker image to build YOCTO based project
#
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# upggade to the latest secure updates
RUN apt-get -q update && \
    apt-get install -y apt-utils && \
    apt-get -q -y upgrade

# Locale
RUN apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

# install essential packages
RUN apt-get install -y \
    sudo \
    curl \
    wget \
    vim mg \
    screen \
    git-core \
    unzip

# install additional DEV tools (build-essential: gcc, g++, libc-dev, dpkg-dev, make)
RUN apt-get install -y \
    build-essential \
    pkg-config

# install yocto essential packages
RUN apt-get install -y \
    ca-certificates \
    software-properties-common \
    gawk wget git-core diffstat unzip texinfo gcc-multilib \
    build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
    xz-utils debianutils iputils-ping libsdl1.2-dev xterm \
    libxslt-dev libglib2.0-dev libc6-dev libpng-dev libncurses-dev libxml2-dev dos2unix \
    zstd liblz4-tool

# OpenEmbedded Self-Test
RUN apt-get install -y python-git

# /bin/sh points to Dash by default, reconfigure to use bash until Android
# build becomes POSIX compliant
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
    dpkg-reconfigure -p critical dash

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install repo
RUN curl -o /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo && chmod a+x /usr/local/bin/repo 

# runqemu requirements
RUN apt-get install -y  net-tools iproute2 iptables policykit-1

# graph requirements
RUN apt-get install -y python3-networkx python3-pygraphviz python3-pydotplus

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/yocto"]

# Work in the build directory, repo is expected to be init'd here
WORKDIR /yocto
# Minimize container size
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY docker/git_config /root/git_config
COPY docker/no_strict_ssh_config /root/ssh_config

# Set environment for DBUS operation
RUN mkdir -p /var/run/dbus/

RUN mkdir -p /start.d

ENV DOCKER_USER yocto
ENV DOCKER_GROUP yocto

COPY yocto/dependency-graph /usr/local/bin

COPY scripts/common-entrypoint.sh /root/docker-entrypoint.sh
RUN chmod 755 /root/docker-entrypoint.sh
ENTRYPOINT ["/root/docker-entrypoint.sh"]
