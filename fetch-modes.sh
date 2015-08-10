#!/bin/bash

function fetch_repo {
  if [ ! -d "$1" ]; then
    echo -e "Fetching $1..."
    git clone "git@github.com:NextThingCo/$1.git"
    pushd "$1"
    git submodule update --init --recursive
    popd
  fi
}

fetch_repo otto-runner
fetch_repo otto-menu
fetch_repo otto-gif-mode
