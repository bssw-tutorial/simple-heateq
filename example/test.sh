#!/bin/bash
# Test downstream application uses

set -e

rm -fr build
mkdir -p build && cd build
cmake -DCMAKE_PREFIX_PATH=../../inst \
      -DCMAKE_INSTALL_PREFIX=../../inst \
	  ..
make
make install

echo "Pkg-config options:"
export PKG_CONFIG_PATH=../../inst/lib/pkgconfig
pkg-config fheateq --cflags
pkg-config fheateq --libs

