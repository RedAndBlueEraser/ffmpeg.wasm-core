#!/bin/bash

set -eo pipefail
source $(dirname $0)/var.sh

if [[ "$FFMPEG_ST" != "yes" ]]; then
  mkdir -p wasm/packages/core/dist
  EXTRA_FLAGS=(
    -pthread
    -s USE_PTHREADS=1                             # enable pthreads support
    -s PROXY_TO_PTHREAD=1                         # detach main() from browser/UI main thread
    -o ../wasm/packages/core/dist/ffmpeg-core.js
  )
else
  mkdir -p wasm/packages/core-st/dist
  EXTRA_FLAGS=(
    -o ../wasm/packages/core-st/dist/ffmpeg-core.js
  )
fi
FFMPEG_PATH=ffmpeg
FLAGS=(
  -I. -I./fftools -I$BUILD_DIR/include
  # -Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavresample -Llibavutil -Lharfbuzz -Llibass -Lfribidi -Llibpostproc -Llibswscale -Llibswresample -L$BUILD_DIR/lib
  # -Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavresample -Llibavutil -Llibpostproc -Llibswscale -Llibswresample -L$BUILD_DIR/lib
  -Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavresample -Llibavutil -Llibswscale -Llibswresample -L$BUILD_DIR/lib
  -Wno-deprecated-declarations -Wno-pointer-sign -Wno-implicit-int-float-conversion -Wno-switch -Wno-parentheses -Qunused-arguments
  # -lavdevice -lavfilter -lavformat -lavcodec -lswresample -lswscale -lavutil -lpostproc -lm -lharfbuzz -lfribidi -lass -lx264 -lx265 -lvpx -lmp3lame -lfdk-aac -lvorbis -lvorbisenc -lvorbisfile -logg -ltheora -ltheoraenc -ltheoradec -lz -lfreetype -lopus -lwebp
  # -lavdevice -lavfilter -lavformat -lavcodec -lswresample -lswscale -lavutil -lpostproc -lm
  -lavdevice -lavfilter -lavformat -lavcodec -lswresample -lswscale -lavutil -lm
  fftools/ffmpeg_opt.c fftools/ffmpeg_filter.c fftools/ffmpeg_hw.c fftools/cmdutils.c fftools/ffmpeg.c
  -s USE_SDL=2                                  # use SDL2
  -s INVOKE_RUN=0                               # not to run the main() in the beginning
  -s EXIT_RUNTIME=1                             # exit runtime after execution
  -s MODULARIZE=1                               # use modularized version to be more flexible
  -s EXPORT_NAME="createFFmpegCore"             # assign export name for browser
  -s EXPORTED_FUNCTIONS="[_main]"  # export main and proxy_main funcs
  -s EXPORTED_RUNTIME_METHODS="[FS, cwrap, ccall, setValue, writeAsciiToMemory]"   # export preamble funcs
  -s INITIAL_MEMORY=16MB                  # 64 KB * 1024 * 16 * 2047 = 2146435072 bytes ~= 2 GB
  -s MAXIMUM_MEMORY=4GB
  -s ALLOW_MEMORY_GROWTH=1
  --pre-js ../wasm/src/pre.js
  --post-js ../wasm/src/post.js
  $OPTIM_FLAGS
  ${EXTRA_FLAGS[@]}
)
echo "FFMPEG_EM_FLAGS=${FLAGS[@]}"

# Patch libtheoraenc.c to define ENOSUP (with ENOTSUP) if not defined
patch -Np1 $FFMPEG_PATH/libavcodec/libtheoraenc.c < $ROOT_DIR/wasm/patches/libtheoraenc-enosup-fix.patch || rm -f $FFMPEG_PATH/libavcodec/libtheoraenc.c.rej

cd $FFMPEG_PATH
emmake make -j
emcc "${FLAGS[@]}"

cd $ROOT_DIR
