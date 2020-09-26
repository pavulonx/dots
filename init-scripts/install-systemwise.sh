#!/bin/bash
DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

install() {
  if ! diff -N --color "$1" "$DIR$1"; then
    printf "\n"
    echo "Found changes while installing $1"
    read -r -p "Is this change ok? [y/N] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        sudo cp -v "$DIR$1"  "$1"
        printf "\n\n"
    fi
  fi
}

install /usr/bin/blurlock
install /usr/bin/lockscreen
install /usr/bin/i3exit
install /usr/local/bin/xflock4
