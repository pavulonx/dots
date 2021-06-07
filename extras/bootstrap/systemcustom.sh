#!/bin/bash
DIR="$(dirname "$(realpath "$0")")"
SRC_TREE="$DIR/tree"

_diff() {
  diff -N --color "$1" "$2"
}

changed=false
_prompt_install() {
  src="$1"
  dst="$2"
  if ! _diff "$dst" "$src"; then
    printf "\n"
    echo "Changes between system: '$dst' and source: '$src'"
    read -r -p "Do you want to apply this change? [y/N] " response </dev/tty
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      sudo cp -v "$src" "$dst"
      changed=true
      printf "\n\n"
    fi
  fi
}

find "$SRC_TREE" -type f | awk -F"$SRC_TREE" '{ print $2}' \
| while read -r system_location; do
  _prompt_install "$SRC_TREE$system_location" "$system_location";
done;

$changed && echo "Changes applied!"
exit 0
