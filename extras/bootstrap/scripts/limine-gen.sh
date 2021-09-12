#!/bin/sh

kernel_cmdline="${LIMINE_LINUX_CMDLINE:-}"

os_name="$(grep -E '^NAME=' /etc/os-release | cut -d'"' -f2)"
hostname="$(cat /etc/hostname)"

header="\
DEFAULT_ENTRY=1
TIMEOUT=5
VERBOSE=yes
"
normal_entries=""
fallback_entries=""

# parse entries
for _kernel in $(find /boot -name 'vmlinuz-*' | sort -u); do
  _kn="${_kernel#*vmlinuz-}";
  _kv="${_kn#linux}"; _kv="${_kv#-}"; _kv="${_kv%-*}"; _kv="${_kv:+ - $_kv}";
  entry="\
PROTOCOL=linux
KERNEL_PATH=boot:///vmlinuz-$_kn"
  [ -n "$kernel_cmdline" ] && entry="$entry
CMDLINE=$kernel_cmdline"
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
  unset _kn
  unset _kv
  unset entry
done

echo "\
# /boot/limine.cfg - limine configuration file
# OS: $os_name
# hostname: $hostname

$header

$normal_entries

$fallback_entries"
