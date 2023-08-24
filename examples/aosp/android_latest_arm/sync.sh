#!/bin/bash

repo init -u https://android.googlesource.com/platform/manifest -b master
repo sync -c -j8
