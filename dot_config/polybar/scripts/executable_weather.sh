#!/bin/sh

weather="$(curl -s "wttr.in/${1:-Wroclaw}?format=%c%t")"
notify-send "$weather"

if echo "$weather" | grep -qE "(Unknown|curl|HTML)" ; then
    echo "WEATHER UNAVAILABLE"
else
    echo " $weather"
fi