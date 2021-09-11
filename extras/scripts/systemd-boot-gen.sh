#!/bin/sh
kernel_cmdline="${SDBOOT_LINUX_CMDLINE:-}"

os_name="$(grep -E '^NAME=' /etc/os-release | cut -d'"' -f2)"
os_id="$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2)"
hostname="$(cat /etc/hostname)"

dst_dir="/boot/loader"

tmproot="$(mktemp -d -p /tmp systemd-boot-gen.XXXX)"
tmpd="$tmproot/loader"
mkdir -p "$tmpd/entries"

backupd="$tmproot-backup"
mkdir -p "$backupd"
cp -r "$dst_dir" "$backupd"

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
linux     /vmlinuz-$_kn"
  [ -n "$kernel_cmdline" ] && entry="$entry
options   $kernel_cmdline"
  [ -e "/boot/intel-ucode.img" ] && entry="$entry
initrd    /intel-ucode.img"

  _title="${os_name}${_kv:+ - $_kv}"
  _id="${os_id}${_kv:+-$_kv}"

  [ -e "/boot/initramfs-$_kn.img" ] && echo "# $index-$_id.conf
title     $_title
$entry
initrd    /initramfs-$_kn.img" > "$tmpd/entries/$index-$_id.conf" &&
  index=$((index + 1))

  [ -e "/boot/initramfs-$_kn-fallback.img" ] && echo "# $index-$_id-fallback.conf
title     $_title - [fallback]
$entry
initrd    /initramfs-$_kn-fallback.img" > "$tmpd/entries/$index-$_id-fallback.conf" &&
  index=$((index + 1))

  unset _kn
  unset _kv
  unset _title
  unset _id
  unset entry
done

echo "Config saved to dir: '$tmpd':"
find "$tmpd" -type f | sort -u

changes=false
printf "\nloader.conf diff:\n"
if diff --color "$dst_dir/loader.conf" "$tmpd/loader.conf"; then echo "No changes"; else changes=true; fi
printf "\nEntries diff:\n"
if diff --color -r -N "$dst_dir/entries" "$tmpd/entries"; then echo "No changes"; else changes=true; fi

! $changes && exit 0;

old_entries="$(LANG=C diff --color -r "$dst_dir/entries" "$tmpd/entries" | grep "^Only in $dst_dir/entries" | cut -d' ' -f4- | awk "{print \"$dst_dir/entries/\"\$1}")"
if [ -n "$old_entries" ]; then
  echo "Old entries:
$old_entries
"
fi

# add -o root
printf "Apply changes? [y/N]: " && read -r resp
case "$resp" in
  y|Y|yes|YES)
    for src_f in $(find "$tmpd" -type f); do
      dst_f="$dst_dir/${src_f#$tmpd/}"
      install -v -D -m0755 "$src_f" "$dst_f"
    done
    for old_e in $old_entries; do
      rm -v "$old_e"
    done
    echo "Done!"
    echo "Saved backup into '$backupd'"
    ;;
  *) :
    ;;
esac
