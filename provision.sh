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

DIR="${BASH_SOURCE%/*}"

# if we are running 
if [[ "${BASH_SOURCE}" == "/tmp/vagrant-shell" ]]; then
  DIR="/stak/sdk"
  echo ${DIR}
fi

if [[ ! -d "${DIR}" ]]; then DIR="${PWD}"; fi

if [[ -d "${DIR}/provisioning-scripts" ]]; then
  source "${DIR}/provisioning-scripts/common.sh"
else
	echo "Could not load common includes at ${BASH_SOURCE}."
	ls -al ${BASH_SOURCE%/*}
	echo "Exiting..."
  exit 1
fi

log "Host: ${HOST}"
if [[ "${HOST}" -eq "Darwin" ]]; then
  # launch provisioning scripts for host
  # we find all files in ./provisioning-scripts and if they
  # have the format 'host-###-<script name>.sh' then run them
  for file in "${DIR}/provisioning-scripts"/*; do
    if [[ -n `echo "$(basename ${file})" | grep -E 'host\-[0-9]{3}\-.*\.sh'` ]]; then
      echo "${cyan}Stak➜ ${magenta}------[ ${green}${file}${magenta} ]------${reset}"
      $file
    fi
  done
elif [[ "${HOST}" -eq "Linux" ]]; then
  # launch provisioning scripts
  # we find all files in ./provisioning-scripts and if they
  # have the format 'guest-###-<script name>.sh' then run them
  for file in "${DIR}/provisioning-scripts"/*; do
    if [[ -n `echo "$(basename ${file})" | grep -E 'guest\-[0-9]{3}\-.*\.sh'` ]]; then
      echo "${cyan}Stak➜ ${magenta}------[ ${green}${file}${magenta} ]------${reset}"
      $file
    fi
  done
else
  error "Unknown OS: ${HOST}. Exiting..."
fi

