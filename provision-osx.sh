#!/usr/bin/env bash

CROSS=/opt/cross
SOURCES=/opt/stak-sources
TARGET="arm-linux-engeabihf"

# libbcm2835
BCM2835_VERSION="1.38"
BCM2835_DIR="$SOURCES/bcm2835-${BCM2835_VERSION}"
BCM2835_URL="http://www.airspayce.com/mikem/bcm2835/bcm2835-${BCM2835_VERSION}.tar.gz"

# libjpeg-turbo
LIBJPEG_VERSION="1.4.0"
LIBJPEG_DIR="$SOURCES/libjpeg-turbo-${LIBJPEG_VERSION}"
LIBJPEG_URL="http://downloads.sourceforge.net/project/libjpeg-turbo/${LIBJPEG_VERSION}/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz"

CFLAGS="-target $TARGET \
        -marm \
        -mfloat-abi=hard -mfpu=vfp"
if [ ! -d "$SOURCES" ]; then
  mkdir -p $SOURCES
fi
# cp Toolchain-RaspberryPi.cmake $SOURCES/Toolchain-RaspberryPi.cmake
if [ ! -d "/opt/vc" ]; then
  # git clone --depth 1 https://github.com/raspberrypi/firmware /opt/rpi-firmware
  if [ ! -d "$SOURCES/userland" ]; then
    git clone --depth 1 https://github.com/raspberrypi/userland.git $SOURCES/userland
  fi
  if [ ! -d "$SOURCES/userland/build" ]; then
    mkdir $SOURCES/userland/build
  fi
  if [ ! -f "$SOURCES/userland/build/.configure.succeeded" ]; then
  pushd $SOURCES/userland/build
  cmake \
        -DCMAKE_C_COMPILER="/opt/cross/ellcc/bin/ecc" \
        -DCMAKE_CXX_COMPILER="/opt/cross/ellcc/bin/ecc++" \
        -DCMAKE_C_FLAGS="-target arm-linux-engeabihf" \
        -DCMAKE_CXX_FLAGS="-target arm-linux-engeabihf" \
        -DCMAKE_SYSTEM_PROCESSOR=arm \
        -DCMAKE_SYSTEM_NAME=Linux \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_CROSSCOMPILING=True \
        .. \
    && touch $SOURCES/userland/build/.configure.succeeded \
    || exit 1
  fi

  if [ ! -f "$SOURCES/userland/build/.build.succeeded" ]; then
    pushd $SOURCES/userland/build
    make \
    && touch $SOURCES/userland/build/.build.succeeded \
    || exit 1
    popd
  fi
  # mv /opt/rpi-firmware/hardfp/opt/vc /opt/vc
  # rm -rf /opt/rpi-firmware
  popd
fi



if [ ! -f "${BCM2835_DIR}/.build.succeeded" ]; then
  if [ ! -d "${BCM2835_DIR}/" ]; then
    wget -P $SOURCES $BCM2835_URL || exit 1
    tar -xzvf $SOURCES/bcm2835-${BCM2835_VERSION}.tar.gz -C $SOURCES || exit 1
    rm $SOURCES/bcm2835-${BCM2835_VERSION}.tar.gz || exit 1
  fi
  pushd ${BCM2835_DIR}/
ELLCC_DIR="/opt/cross/ellcc/bin"
CC="$ELLCC_DIR/ecc"
CXX="$ELLCC_DIR/ecc++"
  CC="$CC" \
  CFLAGS="$CFLAGS -v" \
  AR=$ELLCC_DIR/ecc-ar \
  STRIP=$ELLCC_DIR/ecc-strip \
  RANLIB=$ELLCC_DIR/ecc-ranlib \
  LD="$ELLCC_DIR/ecc-ld -mfloat-abi=softfp -mfpu=vfp" \
  LDFLAGS="-target arm-linux-engeabihf" \
  ./configure \
      --build=i686-darwin \
      --target=$TARGET \
      --host=$TARGET \
      --prefix=$CROSS || exit 1
  make || exit 1
  make install || exit 1
  touch "${BCM2835_DIR}/.build.succeeded" || exit 1
  popd
fi

#   if [ ! -d "${LIBJPEG_DIR}" ]; then
#     if [ ! -f "$SOURCES/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz" ]; then
#       wget -P $SOURCES $LIBJPEG_URL || exit 1
#     fi
#     tar -xzvf $SOURCES/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz -C $SOURCES || exit 1
#     # rm $SOURCES/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz || exit 1
#     pushd ${LIBJPEG_DIR}/
#   
#     CC="arm-linux-gnueabihf-gcc" \
#     AR="arm-linux-gnueabihf-ar" \
#     STRIP="arm-linux-gnueabihf-strip" \
#     RANLIB="arm-linux-gnueabihf-ranlib" \
#     ./configure \
#         --target=arm-linux-gnueabihf \
#         --host=arm-linux-gnueabihf \
#         --build=i686-darwin \
#         --prefix=$CROSS || exit 1
#     make -j 16 || exit 1
#     make install || exit 1
#     popd
#   fi
#   
#   if [ ! -d "$SOURCES/llvm-3.5.1.src" ]; then
#     svn co http://llvm.org/svn/llvm-project/llvm/trunk $SOURCES/llvm
#     wget -P $SOURCES http://llvm.org/releases/3.5.1/llvm-3.5.1.src.tar.xz
#     tar -xvf $SOURCES/llvm-3.5.1.src.tar.xz -C $SOURCES/
#     wget -P $SOURCES http://llvm.org/releases/3.5.1/cfe-3.5.1.src.tar.xz
#     mkdir $SOURCES/llvm-3.5.1.src/tools/clang
#     tar -xvf $SOURCES/cfe-3.5.1.src.tar.xz -C $SOURCES/llvm-3.5.1.src/tools/
#     mv $SOURCES/llvm-3.5.1.src/tools/cfe-3.5.1.src/* $SOURCES/llvm-3.5.1.src/tools/clang
#   
#     # pushd $SOURCES/llvm-3.5.1.src
#     # mkdir build
#     # cd build
#     # ../configure --prefix=/opt/cross --enable-optimized --enable-targets=x86,arm --disable-compiler-version-checks
#     # make -j 8
#     # make install
#     # rm $SOURCES/llvm-3.5.1.src.tar.xz
#     # rm $SOURCES/cfe-3.5.1.src.tar.xz
#   fi
#   if [ ! -d "$SOURCES/libcxx/build" ]; then
#     if [ ! -d "$SOURCES/libcxx" ]; then
#       svn co http://llvm.org/svn/llvm-project/libcxx/trunk $SOURCES/libcxx
#     fi
#     if [ ! -d "$SOURCES/libcxxabi" ]; then
#       svn co http://llvm.org/svn/llvm-project/libcxxabi/trunk $SOURCES/libcxxabi
#     fi
#     pushd $SOURCES/libcxxabi
#   
#     # libcxx first pass
#     pushd $SOURCES/libcxx
#     if [ ! -d "$SOURCES/libcxx/build" ]; then
#       mkdir build
#       cd build
#   
#       for FILE in ../src/*.cpp; do
#         clang++ -c -g -Os -std=c++11 $BUILD_FLAGS -I../include $FILE
#       done
#       arm-linux-gnueabihf-gcc $LDSHARED_FLAGS *.o
#       cp $SOURCES/libcxx/build/libc++.so.1.0 /opt/cross/lib
#       cp -rf $SOURCES/libcxx/include/* /opt/cross/include
#       # make -j 16
#       # make install
#       # rm -rf $SOURCES/libcxx/build
#       popd
#     fi


  #if [ ! -d "$SOURCES/libcxxabi/build" ]; then
  #  mkdir build
  #  cd build
  #  CC=arm-linux-gnueabihf-gcc \
  #  AR=arm-linux-gnueabihf-ar \
  #  STRIP=arm-linux-gnueabihf-strip \
  #  RANLIB=arm-linux-gnueabihf-ranlib \
  #  LD=arm-linux-gnueabihf-ld \
  #  cmake \
  #        -DLIBCXXABI_LIBCXX_PATH=$SOURCES/libcxx \
  #        -DLIBCXXABI_LIBCXX_INCLUDES=$SOURCES/libcxx/include \
  #        -DLLVM_PATH=$SOURCES/llvm-3.5.1.src \
  #        -DCMAKE_C_COMPILER=clang \
  #        -DCMAKE_CXX_COMPILER=clang++ \
  #        -DCMAKE_CXX_FLAGS="-std=c++11" \
  #        -DCMAKE_SYSTEM_PROCESSOR=arm \
  #        -DCMAKE_SYSTEM_NAME=Linux \
  #        -DCMAKE_BUILD_TYPE=Release \
  #        -DCMAKE_CROSSCOMPILING=True \
  #        -DCMAKE_INSTALL_PREFIX=/opt/cross \
  #        ..
  #  make -j 16
  #  make install
  #  popd
  #fi
  #
  #pushd $SOURCES/libcxx
  #if [ ! -d "$SOURCES/libcxx/build" ]; then
  #  mkdir build
  #  cd build
  #  CC=arm-linux-gnueabihf-gcc \
  #  AR=arm-linux-gnueabihf-ar \
  #  STRIP=arm-linux-gnueabihf-strip \
  #  RANLIB=arm-linux-gnueabihf-ranlib \
  #  LD=arm-linux-gnueabihf-ld \
  #  cmake \
  #        -DLIBCXX_CXX_ABI=libcxxabi \
  #        -DLIBCXX_LIBCXXABI_INCLUDE_PATHS=$SOURCES/libcxxabi/include \
  #        -DLIT_EXECUTABLE=$SOURCES/llvm/utils/lit/lit.py \
  #        -DCMAKE_C_COMPILER=clang \
  #        -DCMAKE_CXX_COMPILER=clang++ \
  #        -DCMAKE_SYSTEM_PROCESSOR=arm \
  #        -DCMAKE_SYSTEM_NAME=Linux \
  #        -DCMAKE_BUILD_TYPE=Release \
  #        -DCMAKE_CROSSCOMPILING=True \
  #        -DCMAKE_INSTALL_PREFIX=/opt/cross \
  #        ..
  #  make -j 16
  #  make install
  #  popd
  #fi
# fi