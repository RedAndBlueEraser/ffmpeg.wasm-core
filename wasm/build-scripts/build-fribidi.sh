#!/bin/bash

set -euo pipefail
source $(dirname $0)/var.sh

LIB_PATH=third_party/fribidi
CONF_FLAGS=(
  --prefix=$BUILD_DIR                                 # install library in a build directory for FFmpeg to include
  --host=x86_64-linux
  --enable-shared=no                                  # not to build shared library
  --enable-static=yes
  --disable-dependency-tracking
  --disable-debug
)
echo "CONF_FLAGS=${CONF_FLAGS[@]}"
(cd $LIB_PATH && \
  emconfigure ./autogen.sh "${CONF_FLAGS[@]}")
emmake make -C $LIB_PATH clean
emmake make -C $LIB_PATH install -j || true           # docs generation fails without C2man tool but it is not important as long as the binaries are compiled
cp $LIB_PATH/fribidi.pc $BUILD_DIR/lib/pkgconfig      # finish the compilation process by copying fribidi.pc into the correct destination should the compilation be interrupted by the failing docs generation
