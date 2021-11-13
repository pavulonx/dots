#!/bin/sh

echo "Starting polybars"

# shutdown polybars
if pgrep -u "$(id -u)" -x polybar >/dev/null; then
  echo "killing existing polybars"
  polybar-msg cmd quit
  sleep 1
  killall -q polybar

  # wait until shutdown of existing polybars
  while pgrep -u "$(id -u)" -x polybar >/dev/null; do
    sleep 0.5;
  done
fi

case "$DESKTOP_SESSION" in
  bspwm)  bar=bspwm  ;;
  xmonad) bar=xmonad ;;
  i3)     bar=i3     ;;
  *)      bar=""     ;;
esac

[ -z "$bar" ] && exit 1

# display tray only on primary monitor
monitor_configs="$(LANG=C polybar --list-monitors | sed '
s/:.*primary.*$/|right/g
s/:.*$/|none/g
')"

for mc in $monitor_configs; do
  monitor="${mc%|*}"
  tray_position="${mc#*|}"

  POLYBAR_MONITOR="$monitor" POLYBAR_TRAY_POSITION="$tray_position" polybar "$bar" &
done
