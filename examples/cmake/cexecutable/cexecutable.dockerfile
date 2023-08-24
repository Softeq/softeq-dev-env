#
# Minimum Docker image to build Softeq linux-common-library
#
FROM cmake_builder:ubuntu20

COPY 3rd_party/dependency.h /usr/include

RUN apt-get -qq update && \
    apt-get -q -y upgrade

# install dependendant packages
RUN apt-get install -y \
    libmagic-dev
