#!/bin/sh

OS_NAME="$(grep -Eo '^NAME=".*$' /etc/os-release | cut -d\" -f2)"
OS_COLOR="$(grep -Eo '^ANSI_COLOR=".*$' /etc/os-release | cut -d\" -f2)"

tmpf="$(mktemp)"
cat <<EOF>"$tmpf"
 \e[${OS_COLOR}m$OS_NAME\e[0m \e[1m\n\e[0m \e[0;33m\r\e[0m
 \e[0;35m\l\e[0m

EOF

echo "Example issue banner:"
echo "-----START-------------------------"
agetty --show-issue -f "$tmpf"
echo "------END--------------------------"


if ! diff --color=always "$tmpf" /etc/issue; then
  printf "Difference found. Apply banner? [y/N]: "
  read -r resp
  case "$resp" in
    y|yes|Y|YES)
      sudo rm /etc/issue &&
        sudo cp "$tmpf" /etc/issue &&
        sudo chmod 644 /etc/issue
      ;;
    *) ;;
  esac
fi
