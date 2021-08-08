#!/bin/sh

# support for fallback initramfs

limine_cmdline="${limine_cmdline:-}"

os_name="$(grep -E '^NAME=' /etc/os-release | cut -d'"' -f2)"
hostname="$(cat /etc/hostname)"

header="# /boot/limine.cfg - limine configuration file
# OS: $os_name
# hostname: $hostname

DEFAULT_ENTRY=1
TIMEOUT=5
VERBOSE=yes"
normal_entries=""
fallback_entries=""

for _kernel in $(find /boot -name 'vmlinuz-*' | sort -u); do
  _kn="${_kernel#*vmlinuz-}"
  _kv="${_kn#linux}"; _kv="${_kv#-}"; _kv="${_kv:+ - $_kv}"
  entry="\
PROTOCOL=linux
KERNEL_PATH=boot:///vmlinuz-$_kn"
  [ -n "$limine_cmdline" ] && entry="$entry
CMDLINE=$limine_cmdline"
  [ -e "/boot/intel-ucode.img" ] && entry="$entry
MODULE_PATH=boot:///intel-ucode.img"

  [ -e "/boot/initramfs-$_kn.img" ] && normal_entries="$normal_entries
:${os_name}${_kv}
$entry
MODULE_PATH=boot:///initramfs-$_kn.img
"
  [ -e "/boot/initramfs-$_kn-fallback.img" ] && fallback_entries="$fallback_entries
:${os_name}${_kv} - [fallback]
$entry
MODULE_PATH=boot:///initramfs-$_kn-fallback.img
"
  unset entry
  unset _kn
  unset _kv
done

echo "$header

$normal_entries

$fallback_entries"
