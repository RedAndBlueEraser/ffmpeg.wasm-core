#!/bin/bash

set -euo pipefail
source $(dirname $0)/var.sh

FFMPEG_PATH=ffmpeg
FLAGS=(
  "${FFMPEG_CONFIG_FLAGS_BASE[@]}"
  # --enable-gpl            # required by x264
  # --enable-nonfree        # required by fdk-aac
  --disable-network
  --disable-everything
  --enable-decoder=opus
  --enable-encoder=aac
  --enable-demuxer=matroska
  --enable-muxer=mp4
  --enable-protocol=file
  --enable-filter=aformat,anull,aresample
  # --enable-encoder=libx264        # enable x264 encoder
  # --enable-libx264        # enable x264
  # --enable-libx265        # enable x265
  # --enable-libvpx         # enable libvpx / webm
  # --enable-libmp3lame     # enable libmp3lame
  # --enable-libfdk-aac     # enable libfdk-aac
  # --enable-libtheora      # enable libtheora
  # --enable-libvorbis      # enable libvorbis
  # --enable-libfreetype    # enable freetype
  # --enable-libopus        # enable opus
  # --enable-libwebp        # enable libwebp
  # --enable-libass         # enable libass
  # --enable-libfribidi     # enable libfribidi
  # --enable-libaom         # enable libaom
)
echo "FFMPEG_CONFIG_FLAGS=${FLAGS[@]}"
cd $FFMPEG_PATH
emconfigure ./configure "${FLAGS[@]}"

cd $ROOT_DIR
