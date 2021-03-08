#!/usr/bin/env bash

set -e

config_file="$HOME/.config/chezmoi/chezmoi.toml"

_machine_type="$1"
[ -z "$_machine_type" ] && echo "Specify machine_type" && exit 1

_browser="$(command -v "$2" || echo "$2")"
[ -z "$_browser" ] && echo "Browser is invalid!" && exit 1

template="
[data]
    machine_type = \"$_machine_type\"
    browser = \"$_browser\"
"

echo "$template"
read -r -p "Is this configuration ok? [y/N] " response </dev/tty
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  mkdir -p "$(dirname "$config_file")"
  echo "$template" >"$config_file"
  echo "Saved to $config_file"
  printf "\nDone\n"
else
  printf "\nNo changes have been made\n"
  exit 1
fi
