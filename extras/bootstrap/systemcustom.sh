#!/bin/bash
DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

changed=false
install_systemwise() {
  src="$DIR/$1$2"
  if ! diff -N --color "$2" "$src"; then
    printf "\n"
    echo "Found changes while installing $2"
    read -r -p "Is this change ok? [y/N] " response </dev/tty
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      sudo cp -v "$src" "$2"
      changed=true
      printf "\n\n"
    fi
  fi
}

tree_dir=tree

find "$DIR/$tree_dir" -type f | awk -F"$tree_dir" '{ print $2}' |
  while read -r location; do
    install_systemwise "$tree_dir" "$location";
  done;

  $changed && echo "Changes applied!"
  exit 0
