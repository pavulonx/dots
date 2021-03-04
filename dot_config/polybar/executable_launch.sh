#!/bin/sh

killall -q polybar

case $DESKTOP_SESSION in
	bspwm)  bar=bspwm ;;
	xmonad) bar=xmonad ;;
	i3)     bar=i3 ;;
	*)      bar="" ;;
esac

[ -z "$bar" ] && exit 1

for m in $(polybar --list-monitors | cut -d":" -f1); do
  MONITOR=$m polybar --reload "$bar" &
done
