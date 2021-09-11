#!/bin/sh

kernel_cmdline="${SDBOOT_LINUX_CMDLINE:-}"

os_name="$(grep -E '^NAME=' /etc/os-release | cut -d'"' -f2)"
os_id="$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2)"
hostname="$(cat /etc/hostname)"

tmpd="$(mktemp -d -p /tmp systemd-boot-gen.XXXX)"
mkdir "$tmpd/entries"

loader_conf="\
# loader.conf - systemd-boot configuration file
# os name: $os_name
# os id: $os_id
# hostname: $hostname

timeout 2
default $os_id
console-mode max\
"
echo "$loader_conf" > "$tmpd/loader.conf"

# parse entries
for _kernel in $(find /boot -name 'vmlinuz-*' | sort -u); do
  _kn="${_kernel#*vmlinuz-}";
  _kv="${_kn#linux}"; _kv="${_kv#-}"; _kv="${_kv%-*}";

  entry="\
linux   /vmlinuz-$_kn"
  [ -n "$kernel_cmdline" ] && entry="$entry
options $kernel_cmdline"
  [ -e "/boot/intel-ucode.img" ] && entry="$entry
initrd  /intel-ucode.img"

  _title="${os_name}${_kv:+ - $_kv}"
  _id="${os_id}${_kv:+-$_kv}"

  [ -e "/boot/initramfs-$_kn.img" ] && echo "# $_id.conf
title   $_title
$entry
initrd  /initramfs-$_kn.img
" > "$tmpd/entries/$_id.conf"

  [ -e "/boot/initramfs-$_kn-fallback.img" ] && echo "# $_id-fallback.conf
title   $_title - [fallback]
$entry
initrd  /initramfs-$_kn-fallback.img
" > "$tmpd/entries/$_id-fallback.conf"

  unset _kn
  unset _kv
  unset _title
  unset _id
  unset entry
done

echo "cfg saved to dir: '$tmpd'"
find "$tmpd"
