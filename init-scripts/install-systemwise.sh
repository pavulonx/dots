#!/bin/bash
DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

install_systemwise() {
  src="$DIR/root$1"
  if ! diff -N --color "$1" "$src"; then
    printf "\n"
    echo "Found changes while installing $1"
    read -r -p "Is this change ok? [y/N] " response </dev/tty
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        sudo cp -v "$src"  "$1"
        printf "\n\n"
    fi
  fi
}

find "$DIR/root" -type f | awk -F'root' '{ print $2}' |
while read location; do
    install_systemwise "$location";
done;

