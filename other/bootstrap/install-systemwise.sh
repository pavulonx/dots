#!/bin/bash
DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

install_systemwise() {
  src="$DIR/$1$2"
  if ! diff -N --color "$2" "$src"; then
    printf "\n"
    echo "Found changes while installing $2"
    read -r -p "Is this change ok? [y/N] " response </dev/tty
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        sudo cp -v "$src"  "$2"
        printf "\n\n"
    fi
  fi
}

find "$DIR/root" -type f | awk -F'root' '{ print $2}' |
while read -r location; do
    install_systemwise root "$location";
done;


# override preinstalled manjaro stuff todo: remove manjaro support
if grep -q "manjaro" /etc/os-release; then
  find "$DIR/manjaro" -type f | awk -F'manjaro' '{ print $2}' |
  while read -r location; do
    install_systemwise manjaro "$location";
  done;
fi

echo "Done!"
