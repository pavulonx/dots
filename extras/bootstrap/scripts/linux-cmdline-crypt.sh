#!/bin/sh

[ "$(id -u)" -ne 0 ] &&
  echo "Must be executed with root priviledges" &&
  exit 1
[ -z "$1" ] &&
  echo "Pass path to root device (e.g. /dev/sda1)" &&
  exit 1

! [ -b "$1" ] &&
  echo "'$1' is not a block device!" &&
  exit 1

DEVICE_UUID="$(blkid -s UUID -o value "$1")"

[ -z "$DEVICE_UUID" ] &&
  echo "Cannot get blkid of '$1'" &&
  exit 1

echo "cryptdevice=UUID=$DEVICE_UUID:cryptroot root=/dev/mapper/cryptroot resume=/dev/mapper/cryptroot"
