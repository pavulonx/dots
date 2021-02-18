#!/bin/sh

_prompt() {
  fst=$(echo "$2"  | cut -d ":" -f2-3)
  fst="${fst#:}"
  fst="${fst%:*}"
  [ -z "$fst" ] || sep=" - "
  snd=$(echo "$2"  | cut -d ":" -f4)
  echo "$1  $fst${sep:-""}$snd"
}

_metadata=$(current_player metadata -af "{{status}}:{{artist}}:{{album}}:{{title}}")
_status=$(echo "$_metadata" | cut -d ":" -f1)

if [ "$_status" = "Playing" ]; then
    _prompt "" "$_metadata"
elif [ "$_status" = "Paused" ]; then
    _prompt "" "$_metadata"
fi

