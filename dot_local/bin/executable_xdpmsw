#!/bin/sh

if [ -n "$1" ] ; then
  case "$1" in
    on)     xset +dpms ;;
    off)    xset -dpms ;;
    toggle) xset q  | grep -oq "DPMS is Enabled" && $0 off || $0 on  ;;
    *)      exit 1;
  esac
else
  if xset q  | grep -oq "DPMS is Enabled"; then
      echo "  ON "
  else
      echo "  OFF"
  fi
fi
