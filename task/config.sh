#!/bin/bash -e
# set -x

cd /home/jerin/dpdk.org
rm -rf build
meson build
