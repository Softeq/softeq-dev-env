#!/usr/bin/env bash

THIS_DIR=$(dirname $BASH_SOURCE)
export PATH=$(cd $THIS_DIR/.. && pwd)/bin:$PATH
source $THIS_DIR/completion.bash
