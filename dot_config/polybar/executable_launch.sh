#!/bin/sh

# Terminate already running bar instances
killall -q polybar

echo "$DESKTOP_SESSION" >> ~/polybar_dbg

case $DESKTOP_SESSION in
	bspwm)  bar=bspwm ;;
	xmonad) bar=xmonad ;;
	i3)     bar=i3 ;;
	*)      bar="" ;;
esac

[ -z "$bar" ] && exit 1

if type "xrandr"; then
  for m in $(polybar --list-monitors | cut -d":" -f1); do
    MONITOR=$m polybar --reload "$bar" &
  done
else
  polybar --reload "$bar" &
fi

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch bars
polybar "$bar" &

