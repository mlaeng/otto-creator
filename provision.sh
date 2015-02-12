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


# utility variables
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`
reset=`tput sgr0`

error()
{
  if [ -z "$1" ]; then
    echo "${cyan}Stak➜ ${red}Error occurred! ${reset}"
  else
    echo "${cyan}Stak➜ ${red}Error: $1 ${reset}"
  fi
  exit
}

# environment variables
CROSS="/opt/stak-sdk"
SOURCES="/opt/stak-sources"
TARGET="arm-stak-linux-gnueabihf"
NORMAL_USER=`who | awk '{print $1}'`
homedir=$( getent passwd "$NORMAL_USER" | cut -d: -f6 )
export PATH="$CROSS/bin:$PATH"
echo "export PATH=$CROSS/bin:\$PATH" >> $homedir/.bashrc

# stak toolchain
STAK_TOOLCHAIN_URL="http://stak-images.s3.amazonaws.com/sdk/stak-sdk.tar.bz2"

# libbcm2835
BCM2835_VERSION="1.38"
BCM2835_DIR="$SOURCES/bcm2835-${BCM2835_VERSION}"
BCM2835_URL="http://www.airspayce.com/mikem/bcm2835/bcm2835-${BCM2835_VERSION}.tar.gz"

# libjpeg-turbo
LIBJPEG_VERSION="1.4.0"
LIBJPEG_DIR="$SOURCES/libjpeg-turbo-${LIBJPEG_VERSION}"
LIBJPEG_URL="http://downloads.sourceforge.net/project/libjpeg-turbo/${LIBJPEG_VERSION}/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz"

# get standard build tools

echo "${cyan}Stak➜ ${green}Installing required packages for building...${reset}"
apt-get install -y git make cmake > /dev/null || error "Error getting required packages!"
apt-get -y autoremove > /dev/null

# setup cross development toolchain
if [ ! -d "${CROSS}" ]; then
  wget -P /stak/sdk $STAK_TOOLCHAIN_URL || error "Could not download stak toolchain!"
  echo "${cyan}Stak➜ ${green}Installing SDK to: ${CROSS}${reset}"
  mkdir -p ${CROSS} || error "Error making directory $CROSS"
  tar xjf /stak/sdk/stak-sdk.tar.bz2 -C /opt --strip-components=1 2>&1 > /dev/null \
    || error "Error installing toolchain"
  chown -R vagrant:vagrant  ${CROSS}
fi

# make sources directory for building extra libraries
if [ ! -d "${SOURCES}" ]; then
  echo "${cyan}Stak➜ ${green}Creating sources directory: ${SOURCES}${reset}"
  mkdir -p ${SOURCES}  2>&1 > /dev/null || error "Error creating sources directory"
  chown -R vagrant:vagrant  ${SOURCES}
fi

# download and install raspberry pi userland
if [ ! -d "/opt/vc" ]; then
	git clone --depth 1 https://github.com/raspberrypi/firmware /opt/rpi-firmware  2>&1 > /dev/null \
    || error "Error downloading pi userland"
	mv /opt/rpi-firmware/opt/vc /opt/vc
	rm -rf /opt/rpi-firmware
fi

# build libbcm2835
if [ ! -f "${BCM2835_DIR}/.build.succeeded" ]; then
  if [ ! -d "${BCM2835_DIR}/" ]; then
    echo "${cyan}Stak➜ ${green}Downloading libbcm2835 version ${BCM2835_VERSION}${reset}"
    wget -P $SOURCES $BCM2835_URL || error "Could not download libbcm2835!"
    tar -xzvf $SOURCES/bcm2835-${BCM2835_VERSION}.tar.gz -C $SOURCES 2>&1 > /dev/null \
      || error "Error extracting libbcm2835"
    rm $SOURCES/bcm2835-${BCM2835_VERSION}.tar.gz 2>&1 > /dev/null
  fi
  pushd ${BCM2835_DIR}/
  echo "${cyan}Stak➜ ${green}Building libbcm2835...${reset}"
  $TARGET-gcc -shared -o $CROSS/lib/libbcm2835.a -Isrc src/bcm2835.c > /dev/null \
    || error "Error Building libbcm2835"
  cp src/bcm2835.h $CROSS/include/
  touch "${BCM2835_DIR}/.build.succeeded"
  popd
fi

#   if [ ! -f "${LIBJPEG_DIR}/.build.succeeded" ]; then
#     if [ ! -d "${LIBJPEG_DIR}/" ]; then
#       wget -P $SOURCES $LIBJPEG_URL || exit 1
#       tar -xzvf $SOURCES/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz -C $SOURCES || exit 1
#       rm $SOURCES/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz || exit 1
#     fi
#     pushd ${LIBJPEG_DIR}/
#     CC="$TARGET-gcc" \
#     CXX="$TARGET-g++" \
#     LD="$TARGET-ld" \
#     AR="$TARGET-ar" \
#     RANLIB="$TARGET-ranlib" \
#     STRIP="$TARGET-strip" \
#     ./configure \
#         --build=x86_64-linux-gnu \
#         --target=$TARGET \
#         --host=$TARGET \
#         --prefix=$CROSS || exit 1
#     make -j16 || exit 1
#     make install || exit 1
#     touch "${LIBJPEG_DIR}/.build.succeeded" || exit 1
#     popd
#   fi

#   if [ ! -d "${LIBJPEG_DIR}" ]; then
#     http://downloads.sourceforge.net/project/libjpeg-turbo/1.3.90%20%281.4%20beta1%29/libjpeg-turbo-1.3.90.tar.gz
#     wget -P /opt/sources "http://downloads.sourceforge.net/project/libjpeg-turbo/${LIBJPEG_VERSION}/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz" || exit 1
#     tar -xzvf /opt/sources/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz -C /opt/sources || exit 1
#     rm /opt/sources/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz || exit 1
#     pushd ${LIBJPEG_DIR}/
#     ./configure --host=$TARGET --build=i686-pc-linux-gnu --target=$TARGET --prefix=$CROSS CC=${TARGET}-gcc || exit 1
#     make || exit 1
#     make install || exit 1
#     popd
#   fi
#   
#   
#   #     if [ ! -d "/opt/sources/llvm-3.5.1.src" ]; then
#   #       svn co http://llvm.org/svn/llvm-project/llvm/trunk /opt/sources/llvm
#   #       wget -P /opt/sources http://llvm.org/releases/3.5.1/llvm-3.5.1.src.tar.xz
#   #       tar -xvf /opt/sources/llvm-3.5.1.src.tar.xz -C /opt/sources/
#   #       wget -P /opt/sources http://llvm.org/releases/3.5.1/cfe-3.5.1.src.tar.xz
#   #       mkdir /opt/sources/llvm-3.5.1.src/tools/clang
#   #       tar -xvf /opt/sources/cfe-3.5.1.src.tar.xz -C /opt/sources/llvm-3.5.1.src/tools/
#   #       mv /opt/sources/llvm-3.5.1.src/tools/cfe-3.5.1.src/* /opt/sources/llvm-3.5.1.src/tools/clang
#   #       
#   #       pushd /opt/sources/llvm-3.5.1.src
#   #       mkdir build
#   #       cd build
#   #       ../configure --prefix=/opt/cross --enable-optimized --enable-targets=x86,arm --disable-compiler-version-checks
#   #       make -j 8
#   #       make install
#   #       rm /opt/sources/llvm-3.5.1.src.tar.xz
#   #       rm /opt/sources/cfe-3.5.1.src.tar.xz
#   #     fi
#   #     
#   #     if [ ! -d "/opt/sources/libcxx" ]; then
#   #        svn co http://llvm.org/svn/llvm-project/libcxx/trunk /opt/sources/libcxx
#   #        svn co http://llvm.org/svn/llvm-project/libcxxabi/trunk /opt/sources/libcxxabi
#   #        pushd /opt/sources/libcxxabi
#   #        mkdir build
#   #        cd build
#   #        cmake -DLIBCXXABI_LIBCXX_PATH=/opt/sources/libcxx \
#   #              -DCMAKE_C_COMPILER=clang \
#   #              -DCMAKE_CXX_COMPILER=clang++ \
#   #              -DCMAKE_SYSTEM_PROCESSOR=arm \
#   #              -DCMAKE_SYSTEM_NAME=Linux \
#   #              -DCMAKE_BUILD_TYPE=Debug \
#   #              -DCMAKE_CROSSCOMPILING=True \
#   #              -DCMAKE_INSTALL_PREFIX=/opt/cross \
#   #              ..
#   #        make
#   #        make install
#   #        popd
#   #        pushd /opt/sources/libcxx
#   #        mkdir build
#   #        cd build
#   #        cmake  -DLIBCXX_CXX_ABI=libcxxabi \
#   #               -DLIBCXX_LIBCXXABI_INCLUDE_PATHS=/opt/sources/libcxxabi/include \
#   #               -DLIT_EXECUTABLE=/opt/sources/llvm/utils/lit/lit.py \
#   #               -DCMAKE_C_COMPILER=clang \
#   #               -DCMAKE_CXX_COMPILER=clang++ \
#   #               -DCMAKE_INSTALL_PREFIX=/opt/cross \
#   #               ..
#   #        make
#   #        make install
#   #        popd
#   #     fi
#   #     
#   #     sed -i "/GROUP/c\GROUP ( /opt/cross/lib/libpthread.so.0 /opt/cross/usr/lib/libpthread_nonshared.a )" /opt/cross/usr/lib/libpthread.so
#   
#   # if [ ! -d "/opt/sources/libcxx"]; then
#   #   svn co http://llvm.org/svn/llvm-project/libcxx/trunk /opt/sources/libcxx
#   # fi
#   