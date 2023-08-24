#
# Docker image to build CMake based project
#
FROM ubuntu:20.04

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

# install cmake essential packages
RUN apt-get install -y \
    cmake \
    cmake-curses-gui \
    strace \
    valgrind \
    libgtest-dev \
    libgmock-dev \
    gcovr \
    gnupg \
    dbus \
    dbus-user-session \
    systemd \
    nodejs \
    clangd

# The persistent data will be in these directories, everything else is
# considered to be ephemeral
VOLUME ["/workdir" , "/ccache"]

# Work in the build directory, project sources are expected to be here
WORKDIR /workdir

# Install SonarCube scanner
RUN mkdir -p /opt && \
    cd /opt && \
    [ -f sonar-scanner.zip ] || curl -S https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.5.0.2216-linux.zip -o sonar-scanner.zip 2>&1 && \
    unzip -q sonar-scanner.zip && \
    chmod +x sonar-scanner-4.5.0.2216-linux/bin/* && \
    chmod +x sonar-scanner-4.5.0.2216-linux/jre/bin/* && \
    chmod -R +x sonar-scanner-4.5.0.2216-linux/jre/lib/*
RUN ln -s /opt/sonar-scanner-4.5.0.2216-linux/bin/sonar-scanner /usr/bin/sonar-build-scanner

# Install SonarCube build wrapper
RUN mkdir -p /opt && \
    cd /opt && \
    [ -f sonar-builder.zip ] || curl -S https://sonar.softeq.com/static/cpp/build-wrapper-linux-x86.zip -o sonar-builder.zip 2>&1 && \
    unzip -q sonar-builder.zip && \
    chmod +x build-wrapper-linux-x86/*
RUN ln -s /opt/build-wrapper-linux-x86/build-wrapper-linux-x86-64 /usr/bin/sonar-build-wrapper

# Minimize container size
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY docker/git_config /root/git_config
COPY docker/ssh_config /root/ssh_config

# Set environment for DBUS operation
RUN mkdir -p /var/run/dbus/

RUN mkdir -p /start.d

ENV DOCKER_USER builder
ENV DOCKER_GROUP builder

COPY scripts/cmake-entrypoint.sh /start.d/001-cmake-builder.sh
RUN chmod 755 /start.d/001-cmake-builder.sh

COPY scripts/common-entrypoint.sh /root/docker-entrypoint.sh
RUN chmod 755 /root/docker-entrypoint.sh
ENTRYPOINT ["/root/docker-entrypoint.sh"]
