#!/bin/sh

OS_NAME="$(grep -o '^NAME=\".*$' /etc/os-release | cut -d\" -f2)"
PADDING="$(echo "                                               " | head -c "${#OS_NAME}")"
OS_COLOR="$(grep -o '^ANSI_COLOR=\".*$' /etc/os-release | cut -d\" -f2)"

banner="$(cat <<EOF
 $PADDING  \e[0;35m\l\e[0m
 \e[${OS_COLOR}m$OS_NAME\e[0m  \e[0;33m\r\e[0m
 $PADDING  \e[0;32m\U\e[0m
EOF
)"

echo "Example issue banner:"
echo "-----START-------------------------"
#shellcheck disable=SC2059
printf "$(echo "$banner" | sed "
s~\\\r~$(uname -r)~g
s~\\\l~tty2~g
s~\\\U~3 users~g
")\n"
echo "------END--------------------------"

tmpf="$(mktemp)"
printf '%s\n\n' "$banner" > "$tmpf"

if ! diff --color=always "$tmpf" /etc/issue; then
  printf "Difference found. Apply banner? [y/N]: "
  read -r resp
  case "$resp" in
    y|yes|Y|YES)
      sudo cp /etc/issue /etc/issue.bak &&
        sudo rm /etc/issue &&
        sudo cp "$tmpf" /etc/issue &&
        sudo chmod 644 /etc/issue
      ;;
    *) ;;
  esac
fi
