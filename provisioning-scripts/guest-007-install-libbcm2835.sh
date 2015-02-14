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

# standard include line
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR}" ]]; then DIR="${PWD}"; fi
if [[ -f "${DIR}/common.sh" ]]; then
  source "${DIR}/common.sh"
else
  echo "Could not load common includes at ${BASH_SOURCE%/*}."
  echo "Exiting..."
  exit 1
fi

# libbcm2835
BCM2835_VERSION="1.38"
BCM2835_DIR="${SOURCES}/bcm2835-${BCM2835_VERSION}"
BCM2835_URL="http://www.airspayce.com/mikem/bcm2835/bcm2835-${BCM2835_VERSION}.tar.gz"

if [[ ! -z "$1" ]]; then
  if [[ "$1" -eq "clean" ]]; then
    if [[ -f "${BCM2835_DIR}/.build.succeeded" ]]; then
      rm "${BCM2835_DIR}/.build.succeeded"
    fi
    exit 0
  fi
fi



# build libbcm2835
if [ ! -f "${BCM2835_DIR}/.build.succeeded" ]; then
  if [ ! -d "${BCM2835_DIR}/" ]; then
    log "Downloading libbcm2835 version ${BCM2835_VERSION}"
    wget -q -P ${SOURCES} ${BCM2835_URL} 2>&1 > /dev/null \
      || error "Could not download libbcm2835!"
    tar -xzvf ${SOURCES}/bcm2835-${BCM2835_VERSION}.tar.gz -C ${SOURCES} 2>&1 > /dev/null \
      || error "Error extracting libbcm2835"
    rm $SOURCES/bcm2835-${BCM2835_VERSION}.tar.gz 2>&1 > /dev/null
  fi
  log "Building libbcm2835..."
  ${TARGET}-gcc \
                -o ${BCM2835_DIR}/src/bcm2835.o \
                -I${BCM2835_DIR}/src \
                -c ${BCM2835_DIR}/src/bcm2835.c > /dev/null \
    || error "Error building bcm2835.o"
  ${TARGET}-ar \
                -rcs ${CROSS}/lib/libbcm2835.a \
                ${BCM2835_DIR}/src/bcm2835.o > /dev/null \
    || error "Error linking libbcm2835"
  install ${BCM2835_DIR}/src/bcm2835.h ${CROSS}/include/ \
    || error "Could not install libbcm2835 header"
  touch "${BCM2835_DIR}/.build.succeeded"
fi