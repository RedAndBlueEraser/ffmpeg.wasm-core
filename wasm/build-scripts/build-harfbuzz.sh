#!/bin/bash

set -euo pipefail
source $(dirname $0)/var.sh

LIB_PATH=third_party/harfbuzz
CFLAGS="$CFLAGS -DHB_NO_PRAGMA_GCC_DIAGNOSTIC_ERROR"
# A hacky way to disable pthread
if [[ "$FFMPEG_ST" == "yes" ]]; then
  # sed -i 's#\[have_pthread=true\]#\[have_pthread=false\]#g' $LIB_PATH/configure.ac
  sed -i "s#('HAVE_PTHREAD', 1)#('HAVE_PTHREAD', 0)#g" $LIB_PATH/meson.build
  CFLAGS="$CFLAGS -s USE_PTHREADS=0"
else
  # sed -i 's#\[have_pthread=false\]#\[have_pthread=true\]#g' $LIB_PATH/configure.ac
  sed -i "s#('HAVE_PTHREAD', 0)#('HAVE_PTHREAD', 1)#g" $LIB_PATH/meson.build
fi
CXXFLAGS=$CFLAGS
CONF_FLAGS=(
  --prefix=$BUILD_DIR                                 # install library in a build directory for FFmpeg to include
  --host=i686-gnu                                     # use i686 linux
  --enable-shared=no                                  # not to build shared library
  --enable-static 
)
(cd $LIB_PATH && echo "[binaries]
c = 'emcc'
cpp = 'em++'
ar = 'emar'

[host_machine]
system = 'emscripten'
cpu_family = 'wasm32'
cpu = 'wasm32'
endian = 'little'
" > emscripten.txt)
(cd $LIB_PATH && meson setup --cross-file emscripten.txt --default-library static build-emscripten)
(cd $LIB_PATH && meson configure -Dprefix=$BUILD_DIR -Ddefault_library=static build-emscripten)
(cd $LIB_PATH && meson compile --clean -C build-emscripten)
(cd $LIB_PATH && meson install -C build-emscripten)
