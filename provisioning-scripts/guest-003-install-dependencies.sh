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

# get standard build tools
log "Installing required packages for building..."
apt-get update 2>&1 > /dev/null
  || error "Error. Could not update sources!"
apt-get install -y git make cmake python-pip 2>&1 > /dev/null \
  || error "Error getting required packages!"
apt-get -y autoremove 2>&1 > /dev/null
pip install shyaml 2>&1 > /dev/null \
  || error "Could not install SHYAML"
