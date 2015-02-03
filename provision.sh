#!/usr/bin/env bash
#
# The MIT License (MIT)
#
# Copyright (c) 2015 Next Thing Co.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

CROSS=/opt/cross
TARGET=arm-bcm2708-linux-gnueabi
export PATH=/opt/rpi-tools/arm-bcm2708/arm-bcm2708-linux-gnueabi/bin:$CROSS/bin:$PATH

# libbcm2835
BCM2835_VERSION="1.38"
BCM2835_DIR="/opt/sources/bcm2835-${BCM2835_VERSION}"

# libjpeg-turbo
LIBJPEG_VERSION="1.4.0"
LIBJPEG_DIR="/opt/sources/libjpeg-turbo-${LIBJPEG_VERSION}"

# get standard build tools
apt-get install -y git build-essential libncurses5-dev nasm subversion cmake # clang-3.5 llvm-3.5
# pacman -S base-devel clang llvm ncurses nasm subversion cmake git

# get pi specific build tools
if [ ! -d "/opt/rpi-tools" ]; then
	git clone --depth 1 https://github.com/raspberrypi/tools /opt/rpi-tools
fi

# get pi firmware and copy /opt/vc
if [ ! -d "/opt/vc" ]; then
	git clone --depth 1 https://github.com/raspberrypi/firmware /opt/rpi-firmware
	mv /opt/rpi-firmware/hardfp/opt/vc /opt/vc
	rm -rf /opt/rpi-firmware
fi
	
# add pi build tools to path
echo "export CROSS=/opt/cross" >> /home/vagrant/.bashrc
echo "export TARGET=arm-bcm2708-linux-gnueabihf" >> /home/vagrant/.bashrc
echo "export PATH=/opt/rpi-tools/arm-bcm2708/arm-bcm2708-linux-gnueabi/bin:$CROSS/bin:$PATH" >> /home/vagrant/.bashrc

if [ ! -d "${BCM2835_DIR}" ]; then
  wget -P /opt/sources http://www.airspayce.com/mikem/bcm2835/bcm2835-${BCM2835_VERSION}.tar.gz || exit 1
  tar -xzvf /opt/sources/bcm2835-${BCM2835_VERSION}.tar.gz -C /opt/sources || exit 1
  rm /opt/sources/bcm2835-${BCM2835_VERSION}.tar.gz || exit 1
  pushd ${BCM2835_DIR}/
  ./configure --target=$TARGET --prefix=$CROSS || exit 1
  make || exit 1
  make install || exit 1
  popd
fi

if [ ! -d "${LIBJPEG_DIR}" ]; then
  wget -P /opt/sources "http://downloads.sourceforge.net/project/libjpeg-turbo/${LIBJPEG_VERSION}/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz" || exit 1
  tar -xzvf /opt/sources/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz -C /opt/sources || exit 1
  rm /opt/sources/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz || exit 1
  pushd ${LIBJPEG_DIR}/
  ./configure --host=${TARGET} --target=$TARGET --prefix=$CROSS CC=${TARGET}-gcc || exit 1
  make || exit 1
  make install || exit 1
  popd
fi


if [ ! -d "/opt/sources/llvm-3.5.1.src" ]; then
  svn co http://llvm.org/svn/llvm-project/llvm/trunk /opt/sources/llvm
  wget -P /opt/sources http://llvm.org/releases/3.5.1/llvm-3.5.1.src.tar.xz
  tar -xvf /opt/sources/llvm-3.5.1.src.tar.xz -C /opt/sources/
  wget -P /opt/sources http://llvm.org/releases/3.5.1/cfe-3.5.1.src.tar.xz
  mkdir /opt/sources/llvm-3.5.1.src/tools/clang
  tar -xvf /opt/sources/cfe-3.5.1.src.tar.xz -C /opt/sources/llvm-3.5.1.src/tools/
  mv /opt/sources/llvm-3.5.1.src/tools/cfe-3.5.1.src/* /opt/sources/llvm-3.5.1.src/tools/clang
  
  pushd /opt/sources/llvm-3.5.1.src
  mkdir build
  cd build
  ../configure --prefix=/opt/cross --enable-optimized --enable-targets=x86,arm --disable-compiler-version-checks
  make -j 8
  make install
  rm /opt/sources/llvm-3.5.1.src.tar.xz
  rm /opt/sources/cfe-3.5.1.src.tar.xz
fi

if [ ! -d "/opt/sources/libcxx" ]; then
   svn co http://llvm.org/svn/llvm-project/libcxx/trunk /opt/sources/libcxx
   svn co http://llvm.org/svn/llvm-project/libcxxabi/trunk /opt/sources/libcxxabi
   pushd /opt/sources/libcxxabi
   mkdir build
   cd build
   cmake -DLIBCXXABI_LIBCXX_PATH=/opt/sources/libcxx \
         -DCMAKE_C_COMPILER=clang \
         -DCMAKE_CXX_COMPILER=clang++ \
         -DCMAKE_SYSTEM_PROCESSOR=arm \
         -DCMAKE_SYSTEM_NAME=Linux \
         -DCMAKE_BUILD_TYPE=Debug \
         -DCMAKE_CROSSCOMPILING=True \
         ..
   make
   popd
   pushd /opt/sources/libcxx
   mkdir build
   cd build
   cmake  -DLIBCXX_CXX_ABI=libcxxabi -DLIBCXX_LIBCXXABI_INCLUDE_PATHS=path/to/libcxxabi/include -DLIT_EXECUTABLE=path/to/llvm/utils/lit/lit.py -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ ..
   popd
fi

# if [ ! -d "/opt/sources/libcxx"]; then
#   svn co http://llvm.org/svn/llvm-project/libcxx/trunk /opt/sources/libcxx
# fi