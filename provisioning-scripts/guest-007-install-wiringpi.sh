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

# wiringpi
WIRINGPI_VERSION="5edd177"
WIRINGPI_DIR="${SOURCES}/wiringPi-${WIRINGPI_VERSION}"
WIRINGPI_URL="https://git.drogon.net/?p=wiringPi;a=snapshot;h=${WIRINGPI_VERSION};sf=tgz"

if [[ ! -z "$1" ]]; then
  if [[ "$1" -eq "clean" ]]; then
    if [[ -f "${WIRINGPI_DIR}/.build.succeeded" ]]; then
      rm "${WIRINGPI_DIR}/.build.succeeded"
    fi
    exit 0
  fi
fi

# build wiringpi
if [ ! -f "${WIRINGPI_DIR}/.build.succeeded" ]; then
  if [ ! -d "${WIRINGPI_DIR}/" ]; then
    log "Downloading wiringpi version ${WIRINGPI_VERSION}"
    wget  -O "${SOURCES}/wiringpi-${WIRINGPI_VERSION}.tar.gz" ${WIRINGPI_URL} \
      || error "Could not download wiringpi!"
    tar -xzvf ${SOURCES}/wiringpi-${WIRINGPI_VERSION}.tar.gz -C ${SOURCES} 2>&1 > /dev/null \
      || error "Error extracting wiringpi"
    rm $SOURCES/wiringpi-${WIRINGPI_VERSION}.tar.gz 2>&1 > /dev/null
  fi
  log "Building wiringpi..."
  sed -e "s/DESTDIR=/DESTDIR:=/" -i ${WIRINGPI_DIR}/wiringPi/Makefile
  sed -e "s/PREFIX=/PREFIX:=/" -i ${WIRINGPI_DIR}/wiringPi/Makefile
  pushd "${WIRINGPI_DIR}/wiringPi"
  #> /dev/null
  CC=${TARGET}-gcc make \
    || error "Error building wiringpi"
  install -m 0755 libwiringPi.so.* ${CROSS}/lib
  install -m 0644 *.h ${CROSS}/include/
  #DESTDIR=${CROSS} PREFIX="" make install \
  #  || error "Could not install wiringpi"
  popd
  touch "${WIRINGPI_DIR}/.build.succeeded"
fi