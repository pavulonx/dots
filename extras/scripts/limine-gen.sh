#!/bin/sh

# support for fallback initramfs

limine_cmdline="${limine_cmdline:-}"

os_name="$(grep -E '^NAME=' /etc/os-release | cut -d'"' -f2)"
hostname="$(cat /etc/hostname)"

output='# limine.cfg configuration file
'
output="$output
DEFAULT_ENTRY=1
TIMEOUT=5
VERBOSE=yes
"

for _kernel in $(find /boot -name 'vmlinuz-*'); do
  _kernel_name="$(echo $_kernel | awk -F'vmlinuz-' '{ print $2 }')"
  output="$output
:$os_name - $_kernel_name
PROTOCOL=linux
KERNEL_PATH=boot:///vmlinuz-$_kernel_name"
  [ -n "$limine_cmdline" ] && output="$output
CMDLINE=$limine_cmdline"
  [ -e "/boot/intel-ucode.img" ] && output="$output
MODULE_PATH=boot:///intel-ucode.img"
  [ -e "/boot/initramfs-$_kernel_name.img" ] && output="$output
MODULE_PATH=boot:///initramfs-$_kernel_name.img"
  output="$output
"
done

echo "$output"
