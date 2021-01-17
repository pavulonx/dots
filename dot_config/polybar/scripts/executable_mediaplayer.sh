#!/bin/sh

_metadata=$(current_player metadata -af "{{status}}:{{artist}}:{{album}}:{{title}}")

_status=$(echo "$_metadata" | cut -d ":" -f1)

artist=$(echo "$_metadata"  | cut -d ":" -f2)
album=$(echo "$_metadata"  | cut -d ":" -f3)
title=$(echo "$_metadata"  | cut -d ":" -f4)

fst=${artist:-$album}
player_info="${fst+"$fst - "}$title"

if [ "$_status" = "Playing" ]; then
    echo "  $player_info"
elif [ "$_status" = "Paused" ]; then
    echo "  $player_info"
else
    echo ""
fi

