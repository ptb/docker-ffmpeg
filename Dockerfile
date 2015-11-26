FROM debian:jessie
# MAINTAINER Peter T Bosse II <ptb@ioutime.com>

RUN echo "debconf debconf/frontend select noninteractive" | debconf-set-selections \

  && FFMPEG_PACKAGES="autoconf build-essential libfaac-dev libfreetype6-dev libfrei0r-ocaml-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libopus-dev libspeex-dev libtheora-dev libtool libvo-aacenc-dev libvo-amrwbenc-dev libvorbis-dev libvpx-dev libwebp-dev libx264-dev libxvidcore-dev pkg-config wget yasm" \

  && sed \
    -e "s/jessie main/jessie main contrib non-free/" \
    -e "s/httpredir.debian.org/debian.mirror.constant.com/" \
    -i /etc/apt/sources.list \

  && apt-get update -qq \
  && apt-get install -qqy \
    $FFMPEG_PACKAGES \

  && mkdir -p /tmp/src/ \

  && wget \
    --no-check-certificate \
    --output-document - \
    --quiet \
    https://api.github.com/repos/mstorsjo/fdk-aac/tarball/master \
    | tar -xz -C /tmp/src/ \
  && cd /tmp/src/mstorsjo-fdk-aac*/ \
  && autoreconf -fiv \
  && ./configure \
    --disable-shared \
    --prefix=/tmp \
  && make -j 2 \
  && make install \
  && make distclean \

  && wget \
    --no-check-certificate \
    --output-document - \
    --quiet \
    https://api.github.com/repos/FFmpeg/FFmpeg/tarball/n2.8.2 \
    | tar -xz -C /tmp/src/ \
  && cd /tmp/src/FFmpeg-FFmpeg*/ \
  && wget \
    --no-check-certificate \
    --output-document - \
    --quiet \
    https://gist.github.com/outlyer/4a88f1adb7f895b93fd9/raw/ffmpeg-2.8-defaultstreams.patch \
    | patch -p1 \
  && PATH="/tmp/bin:$PATH" \
  && PKG_CONFIG_PATH="/tmp/lib/pkgconfig" \
  && ./configure \
    --prefix=/tmp \
    --bindir=/home/ffmpeg \
    --shlibdir=/home/ffmpeg/lib \
    --enable-gpl \
    --enable-version3 \
    --enable-nonfree \
    --enable-static \
    --disable-shared \
    --enable-small \
    --enable-runtime-cpudetect \
    --enable-gray \
    --enable-swscale-alpha \
    --disable-ffplay \
    --disable-ffserver \
    --disable-doc \
    --enable-avdevice \
    --enable-avcodec \
    --enable-avformat \
    --enable-avutil \
    --enable-swresample \
    --enable-swscale \
    --enable-postproc \
    --enable-avfilter \
    --enable-avresample \
    --enable-pthreads \
    --disable-w32threads \
    --disable-os2threads \
    --enable-network \
    --enable-dct \
    --enable-dwt \
    --enable-error-resilience \
    --enable-lsp \
    --enable-lzo \
    --enable-mdct \
    --enable-rdft \
    --enable-fft \
    --enable-faan \
    --enable-pixelutils \
    --enable-avisynth \
    --enable-bzlib \
    --enable-frei0r \
    --enable-iconv \
    --enable-libfaac \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopus \
    --enable-libspeex \
    --enable-libtheora \
    --enable-libvo-aacenc \
    --enable-libvo-amrwbenc \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libxvid \
    --enable-lzma \
    --enable-xlib \
    --enable-zlib \
    --pkg-config-flags="--static" \
    --extra-cflags="-I/tmp/include -static" \
    --extra-ldflags="-L/tmp/lib -static" \
    --enable-hardcoded-tables \
    --disable-debug \

  && PATH="/tmp/bin:$PATH" \
    make \
  && make install \
  && make distclean \

  && apt-get purge -qqy --auto-remove \
    $FFMPEG_PACKAGES \
  && apt-get clean -qqy \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
