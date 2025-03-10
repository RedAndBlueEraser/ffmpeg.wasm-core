#!/bin/bash

set -euo pipefail
source $(dirname $0)/var.sh

LIB_PATH=third_party/libwebp

if [[ "$FFMPEG_ST" == "yes" ]]; then
  EXTRA_CM_FLAGS="-DWEBP_USE_THREAD=OFF"
else
  EXTRA_CM_FLAGS="-DWEBP_USE_THREAD=ON"
fi

CM_FLAGS=(
  -DCMAKE_INSTALL_PREFIX=$BUILD_DIR
  -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_FILE
  -DBUILD_SHARED_LIBS=OFF
  -DZLIB_LIBRARY=$BUILD_DIR/lib
  -DZLIB_INCLUDE_DIR=$BUILD_DIR/include
  -DWEBP_ENABLE_SIMD=ON
  -DWEBP_BUILD_ANIM_UTILS=OFF
  -DWEBP_BUILD_CWEBP=OFF
  -DWEBP_BUILD_DWEBP=OFF
  -DWEBP_BUILD_GIF2WEBP=OFF
  -DWEBP_BUILD_IMG2WEBP=OFF
  -DWEBP_BUILD_VWEBP=OFF
  -DWEBP_BUILD_WEBPINFO=OFF
  -DWEBP_BUILD_LIBWEBPMUX=OFF
  -DWEBP_BUILD_WEBPMUX=OFF
  -DWEBP_BUILD_EXTRAS=OFF
  ${EXTRA_CM_FLAGS-}
)
echo "CM_FLAGS=${CM_FLAGS[@]}"

cd $LIB_PATH
mkdir -p build
cd build
emmake cmake .. -DCMAKE_C_FLAGS="$CXXFLAGS" ${CM_FLAGS[@]}
emmake make clean
emmake make install
cd $ROOT_DIR
