#!/bin/bash

# this script should only be sourced
if [[ "$(basename -- "$0")" == "prepare_env.sh" ]]; then
    echo "Please do not run $0, source it" >&2
    exit 1
fi

source sources/poky/oe-init-build-env build
