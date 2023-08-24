#!/bin/bash

source prepare_env.sh
make 2>&1 | tee build.out
