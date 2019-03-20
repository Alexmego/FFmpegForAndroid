#!/bin/bash
#配置ndk的路径
NDK=/Users/AlphaGo/development/android-ndk-r14b
#指定Android版本指定架构的so库和头文件
PLATFORM=$NDK/platforms/android-21/arch-arm
TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64
CPU=armv7-a
#输出路径
PREFIX=./android/$CPU
function build_ffmpeg
{
    echo "开始编译ffmpeg"
    ./configure \
    --prefix=$PREFIX \
    --target-os=android \
    --cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi- \
    --arch=arm \
    --cpu=$CPU  \
    --sysroot=$PLATFORM \
    --extra-cflags="$CFLAG" \
    --cc=$TOOLCHAIN/bin/arm-linux-androideabi-gcc \
    --nm=$TOOLCHAIN/bin/arm-linux-androideabi-nm \
    --disable-shared \
    --enable-static \
    --enable-runtime-cpudetect \
    --enable-gpl \
    --enable-small \
    --enable-cross-compile \
    --disable-debug \
    --disable-doc \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    --disable-postproc \
    --disable-avdevice \
    --disable-symver \
    --disable-stripping \
    $ADD 
    make -j16
    make install
    echo "编译结束！"
}

echo "编译不支持neon和硬解码"
CPU=armv7-a
PREFIX=./androidV2/$CPU
CFLAG="-I$PLATFORM/usr/include -fPIC -DANDROID -mfpu=vfp -mfloat-abi=softfp "
ADD=
build_ffmpeg

# 将静态库链接成一个动态库
BIN_PREFIX=arm-linux-androideabi
$TOOLCHAIN/bin/${BIN_PREFIX}-ld \
      -rpath-link=$PLATFORM/usr/lib \
      -L$PLATFORM/usr/lib \
      -L$PREFIX/lib \
      -soname libffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o \
      $PREFIX/libffmpeg.so \
      $PREFIX/lib/libavcodec.a \
      $PREFIX/lib/libavfilter.a \
      $PREFIX/lib/libavformat.a \
      $PREFIX/lib/libavutil.a \
      $PREFIX/lib/libswresample.a \
      $PREFIX/lib/libswscale.a \
      -lc -lm -lz -ldl -llog \
      $TOOLCHAIN/lib/gcc/${BIN_PREFIX}/4.9.x/libgcc.a