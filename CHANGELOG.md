# softeq-dev-env
All notable changes to this project will be documented in this file.

The format of the file is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
Please use [Release workflow](https://portal.softeq.com/display/SDD/Git+flow#Gitflow-Releaseworkflow) and [Commit messages style guide](https://portal.softeq.com/display/SDD/Git+flow#Gitflow-Commitmessagesstyleguide)

See [README.md](README.md) for more details.

## [0.1.0] - 2023-08-24
Initial Release

### Added
- Yocto project config version builder
- android emulator support in aosp10
- .clang-format for all С++ projects
- Flutter yocto example for beagleboneblack
- BeagleBone Black yocto example
- Add docker ignore file to exclude unwanted dirs from caching during docker build
- Support component model (CMake)
- Add support for gui applications in cmake docker
- Bash completion for sq-????-build using --help
- New YOCTO example with tinylinux (2MB rootfs)

### Changed
- Merge all docker build systems into single repo

[0.1.0]: https://stash.softeq.com/projects/emblab/repos/softeq-dev-env/browse?at=406f20a
