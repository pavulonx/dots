#!/bin/sh

kernel_cmdline="${SDBOOT_LINUX_CMDLINE:-}"

os_name="$(grep -E '^NAME=' /etc/os-release | cut -d'"' -f2)"
os_id="$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2)"
hostname="$(cat /etc/hostname)"

tmpd="$(mktemp -d -p /tmp systemd-boot-gen.XXXX)/loader"
mkdir -p "$tmpd/entries"

index=1
loader_conf="\
# loader.conf - systemd-boot configuration file
# os name: $os_name
# os id: $os_id
# hostname: $hostname

timeout 2
default $index-$os_id
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

  [ -e "/boot/initramfs-$_kn.img" ] && echo "# $index-$_id.conf
title   $_title
$entry
initrd  /initramfs-$_kn.img
" > "$tmpd/entries/$index-$_id.conf" &&
  index=$((index + 1))

  [ -e "/boot/initramfs-$_kn-fallback.img" ] && echo "# $index-$_id-fallback.conf
title   $_title - [fallback]
$entry
initrd  /initramfs-$_kn-fallback.img
" > "$tmpd/entries/$index-$_id-fallback.conf" &&
  index=$((index + 1))

  unset _kn
  unset _kv
  unset _title
  unset _id
  unset entry
done

echo "Config saved to dir: '$tmpd':"
find "$tmpd" -type f | sort -u

printf "\n\nloader.conf diff:\n\n"
diff --color "/boot/loader/loader.conf" "$tmpd/loader.conf"

printf "\n\nEntries diff:\n\n"
diff --color -r -N "/boot/loader/entries" "$tmpd/entries" 2>/dev/null

old_entries="$(LANG=C diff --color -r "/boot/loader/entries" "$tmpd/entries" 2>/dev/null | grep '^Only in /boot/loader/entries' | cut -d' ' -f4- | awk '{print "/boot/loader/entries/"$1}')"
if [ -n "$old_entries" ]; then
  echo "Old entries:
$old_entries
"
fi
