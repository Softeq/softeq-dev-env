#!/bin/bash

# this script should only be sourced
if [[ "$(basename -- "$0")" == "prepare_env.sh" ]]; then
    echo "Please do not run $0, source it" >&2
    exit 1
fi

#by default cmake registry is used
export CMAKE_ENABLE_REGISTRY=false

