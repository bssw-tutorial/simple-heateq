#!/bin/bash

LOCALROOT=$PWD/inst

set -e
mkdir -p build
mkdir -p inst
cd build
cmake -DCMAKE_PREFIX_PATH=$LOCALROOT -DCMAKE_INSTALL_PREFIX=$LOCALROOT ..
make -j4

(cd tests && ctest)
make install
