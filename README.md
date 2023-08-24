# Docker.io Build Environment

Docker-based system is designed to provide a stable environment for every developer to build a variety of CMake, Yocto and AOSP based projects while eliminating the need for thorough manual configuration of build environment

The same robust Docker images and stable building environment have to be reused on production build and integration test servers by all the developers without having to worry about breaking the delicate project build due to package updates on a local system
The devs will catch the issues with build environment first

## Table of Сontents

- [Prerequisites](#prerequisites)
- [softeq-dev-env repository](#softeq-dev-env-repository)
- [softeq-dev-env directory structure](#softeq-dev-env-directory-structure)
- [Docker images](#install)
- [Building scripts](#building-scripts)
  - [Common launching options](#common-launching-options)
  - [`sq-cmake-build` launching options](#sq-cmake-build-launching-options)
  - [`sq-aosp-build` launching options](#sq-aosp-build-launching-options)
  - [`sq-yocto-build` launching options](#sq-yocto-build-launching-options)
- [Environment variables](#environment-variables)
- [Known Issues](#known-issues)

## <a name="prerequisites"></a>Prerequisites

Complete the [Working Environment Setup Guide](https://portal.softeq.com/display/SDD/Working+Environment+Setup+Guide)

This guide have been tested on [Ubuntu 22.04 LTS](https://releases.ubuntu.com/22.04/) (minimal install)
Adjust it accordingly if you are using another OS distribution

Install Docker.io, gawk
`sudo apt install docker.io gawk`

Add your user to docker group
`sudo adduser $USER docker`

Relogin into the system to get your group membership re-evaluated

If you need more details about docker configuration check out [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)

## <a name="softeq-dev-env-repository"></a>`softeq-dev-env` repository

Switch to your projects directory root, i.e.
`cd ~/Projects`
>The environment is installed in-place where you put it and can not be changed after installation (check out `make install` below)

Clone softeq-dev-env repository
`git clone git@github.com:Softeq/softeq-dev-env.git`

Switch to your new development environment directory
`cd softeq-dev-env`

## <a name="softeq-dev-env-directory-structure"></a>`softeq-dev-env` directory structure

```
├─bin       # building and deployment scripts
│ ├─sq-aosp-build    # Android building script
│ ├─sq-cmake-build   # CMAKE building script
│ ├─sq-release-notes # script to generate changelog from git log
│ └─sq-yocto-build   # Yocto projects building script
├─ci        # Continuous integration scripts
├─cmake     # CMake stuff
├─docker    # docker files
├─examples  # root folder for examples
│ ├─aosp      # Android examples
│ ├─cmake     # CMAKE examples
│ └─yocto     # Yocto examples
├─ide       # IDE integration support files
│ └─.vscode         # Visual Studio Code integration files
└─scripts   # service scripts used by building system
└─yocto     # YOCTO stuff: graph dependency generator
```

Check out dedicated README files in subdirectories:
- [examples](examples/README.md)
- [IDE integration](ide/README.md)

## <a name="install"></a>Build and install

Build docker images and set PATH variable

Make sure you are in your `softeq-dev-env` directory, i.e.
`cd ~/Projects/softeq-dev-env`

To show all the available options
`make help`

To build all the docker images
`make docker`

Bash command line completion is supported to help you build individual images, i.e. to build Yocto docker image
`make docker/yocto`

To pass additional parameters into docker builder use option `P=<addons>`
I.e. to rebuild cmake docker image from scratch use `--no-cache` addon
`make docker/cmake-ubuntu20 P=--no-cache`

Add docker scripts directory to the `PATH` environment variable
`make install`

Relogin into the system to make changes to take effect
Make sure your PATH environment variable contains `/softeq-dev-env/bin`
`echo $PATH`

From here your development environment is set up and ready to use

## <a name="building-scripts"></a>Building scripts

Building scripts are responsible for the following tasks:
- Initialize environment variables with default values
- Passes additional parameters inside the docker
- Run docker container and inside it run sync sources procedure that will download all the needed sources
- Prepare development environment and run build target script which will initiate building process
- Terminating the docker container when everything is done

Before invoking building script make sure it's pointing to appropriate version (usually in your softeq-dev-env/bin directory) i.e.
`which sq-yocto-build` or `which sq-cmake-build`
It's important if you are working with different versions of building system and have made several installs from different locations
>See [Known Issues](#known-issues) section and [troubleshooting guides](https://portal.softeq.com/display/SDD/Troubleshooting)

### <a name="common-launching-options"></a>Common launching options

```bash
 --silent                # Suppress console output
 --gui                   # Provide GUI support
 --image <DOCKER_IMAGE>  # Force using docker image name (REPOSITORY:TAG format?)
 --non-interactive       # force non interactive docker launch (overrides default behavior and DOCKER_INTERRATIVE env)
 --help                  # get help screen
```
Help command (--help) is autodocumented for each script, call it for detailed description
### <a name="sq-cmake-build-launching-options"></a>`sq-cmake-build` launching options

Usage examples:
```bash
```

### <a name="sq-aosp-build-launching-options"></a>`sq-aosp-build` launching options

Usage examples:
```bash
```

### <a name="sq-yocto-build-launching-options"></a>`sq-yocto-build` launching options

Usage examples:
```bash
```

Migration is not required and designed. We do not have backward compatibility.
But the script may have other changes. In order to track them the version is the string with a template like <config_version>.<other_version>
#### History of project.setup
##### Version: 0
```bash
# Example of project.setup file.
# Implementation of each function is mandatory. Assumed, they will be called from <ROOT_WORKDIR> dir inside docker

# This script should only be sourced
if [ "$(basename -- "$0")" == "project.setup" ]; then
  echo "Please do not run $0, source it" >&2
  exit 1
fi
YOCTO_CONF_VERSION="0.x"
#Initializes workdir for the project (ie init repo)
function do_init
{
}
#Returns status of sources in the workdir. it can return (echo) "empty" (means: workdir must be initialized), "ready" (sync is not required)
function do_state
{
}
#Source synchronisation
function do_sync
{
}
#Prepares dev environment inside the docker
function do_prepare
{
}
#Prebuild step before the building and after source sychronisation and environment preparation
function do_workspace
{
}
#Does the building
function do_build
{
}
#Cleans workdir
function do_clean
{
}
```

## <a name="environment-variables"></a>Environment variables

Environment variables used by build system to fine control over [docker run](https://docs.docker.com/engine/reference/commandline/run/)

```
- DOCKER_EXTRA_ARGS={docker_options}      # specify additional docker parameters
- DOCKER_WORKDIR=docker_path              # set root folder inside the docker container
- DOCKER_VOLUMES={host_path:docker_path;} # list of additional mount points inside the docker container
- DOCKER_ENVS={variable=value;}           # list of environment variables to pass in the docker container
- DOCKER_DEVS={device{:option};}          # add a host device(s) to the container (docker --device option)
- DOCKER_INTERACTIVE=true|false           # explicitly force enable/disable interactive mode
- DOCKER_IMAGE=image_name[:image_tag]     # specify docker image to use, i.e. `android_builder:aosp8` (default image tag latest can be ommited)
```

Export them as necessary in your building pipeline

## <a name="known-issues"></a>Known Issues

- Sometimes parent container can be changed on docker repositories side which may lead to `404 error` at build time
    To fix this problem rebuild the docker image(s) from scratch
    `make docker P=--no-cache`
