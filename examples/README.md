# Using the softeq development environment to build examples

## Table of contents

- [Prerequisites](#prerequisites)
- [Building AOSP example](#building-aosp-example)
- [Building raspberry example from Yocto docker](#building-raspberry-example)
- [Building qemuarm to run raspberry example on emulator](#building-qemuarm-to-run-raspberry-example-on-emulator)
- [Building example from Cmake docker](#building-example-from-cmake-docker)

## <a name="prerequisites"></a>Prerequisites

[Follow the guide](../README.md) to set up your development environment

It's safe to build examples right in the appropriate subdirectory of [softeq-dev-env](../examples/)

When using an example as a new project template always copy its contents to your working directory

>Some of the examples are quite spacy after build so consider removing unnecessary binary files when done `TODO: consult with Victor about using 'clean' option here`

## <a name="building-aosp-example"></a>Building AOSP example

Make sure you have built appropriate docker image, i.e. `android_builder:aosp8`   
`docker images`

Export `DOCKER_IMAGE` environment variable  
`export DOCKER_IMAGE=android_builder:aosp8`

Change directory to example folder, i.e.  
`cd ~/repos/softeq-dev-env/examples/aosp/x86`

Build raspberry example  
`sq-aosp-build`

## <a name="building-raspberry-example"></a>Building raspberry example

Make sure that you have built `yocto-builder:latest` docker  
`docker images`

Change directory to example folder, i.e.  
`cd ~/repos/softeq-dev-env/examples/yocto/raspberry`

Build raspberry example  
`sq-yocto-build`

Check out `sq-yocto-build deploy` command to deploy the example on real hardware  

## <a name="building-qemuarm-to-run-raspberry-example-on-emulator"></a>Building qemuarm to run raspberry example on emulator

It's possible to build the [raspberry example](#building-raspberry-example) for running in virtual environment

Edit `./sync.sh` to adjust it for building ARM emulator:  
remove `rpi-sdimg` from `IMAGE_TYPE="tar.xz ext3 rpi-sdimg"` statement  
replace `raspberrypi3` with `qemuarm` in `MACHINE=` statement

Build the example to run on emulator  
`sq-yocto-build`

Run the example in docker container on ARM emulator  
`sq-yocto-build -- runqemu qemuarm slirp nographic`

Login with `root` username (no password required)

Do whatever you need inside emulated environment, i.e.  
`dmesg | grep CPU:` to make sure we have booted into ARM environment 

To shutdown emulated system  
`halt`

To terminate QEMU press `[Ctrl]+[A] [x]`

## <a name="building-example-from-cmake-docker"></a>Building example from Cmake docker

Make sure you have built `cmake-builder:ubuntu20` docker  
`docker images`

Change directory to example folder, i.e.  
`cd ~/repos/softeq-dev-env/examples/cmake/cexecutable`

Build the new docker image for the current project  
`sq-cmake-build docker`

Make sure you have built `cexecutable-builder:latest` docker  
`docker images`

If necessary specify the work directory as the persistent file store for the `sq-cmake-build` wrapper  
`export CMAKE_VOL=<PATH_TO_WORKDIR>`

By default sq-cmake-build will use your current directory

Building script is looking for specific docker image to use in the following order:
- parameter of `--image` building script option
- CMAKE_IMAGE environment variable  
(Use `export CMAKE_IMAGE=<YOUR_DOCKERFILE_NAME>` if necessary)
- FROM statement of the ONLY docker file located in the current directory
- If no docker files found in the current directory you will be prompted to define CMAKE_IMAGE (or you can copy/create appropriate docker file instead)
- If multiple docker files are located in the current directory you will be prompted to define CMAKE_IMAGE environment variable (or you can use `--image` building script option instead)

Build `cexecutable` project in docker  
`sq-cmake-build dev`
