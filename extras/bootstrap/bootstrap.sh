#!/bin/sh
# Debloated version of LARBS by Luke Smith <luke@lukesmith.xyz>
# License: GNU GPLv3

### OPTIONS AND VARIABLES ###
bootstrap_hostname="${bootstrap_hostname:-}"
bootstrap_timezone="${bootstrap_timezone:-"Europe/Warsaw"}"

[ -z "$bootstrap_hostname" ] && echo "bootstrap_hostname is not set" && exit 1
[ -z "$bootstrap_timezone" ] && echo "bootstrap_timezone is not set" && exit 1

logfile="$(mktemp -p /tmp 'bootstrap-XXXXX.log')"
echo "Pacman logs will be stored in $logfile"

### FUNCTIONS ###
_log() {
  pad='─────────────────────────────────────────────────────────────────────────────'
  num="$*"; num="${#num}"
  sep="$(echo "$pad" | head -c $(((num + 3) * 3)))"
  echo ''
  printf '\e[0;32;1m=> %s\e[0m\n' "$1"
  echo "$sep"
}

_error() {
  echo "bootstrap:error: [$*]" >> "$logfile"
  printf '\e[0;31;1m%s\e[0m\n' "$*" >&2
  exit 1
}

installpkg() {
  echo "bootstrap:installpkg: [$*]" >> "$logfile"
  LANG=C pacman --noconfirm --needed -S "$@" 2>&1 | tee -a "$logfile" | grep -v 'is up to date -- skipping'
}

_add_user_with_pass() {
  echo "Enter a name for the user account: " && read -r username
  while ! echo "$username" | grep -q "^[a-z_][a-z0-9_-]*$"; do
    echo "Username not valid. Give a username beginning with a letter, with only lowercase letters, - or _."
    printf "Enter a name for the user account: " && read -r username
  done
  if id -u "$username" > /dev/null 2>&1; then
    echo "WARNING! The user \`$username\` already exists on this system. LARBS can install for a user already existing, but it will overwrite any conflicting settings/dotfiles on the user account and will change $username's password to the one you just gave."
    printf "Do you want to continue? [y/N]: " && read -r response;
    case "$response" in
      y|Y|yes|YES) ;;
      *) exit 1;;
    esac
  fi
  echo "Adding user '$username'"
  export username
  useradd -m -s /bin/zsh -U "$username" > /dev/null 2>&1
  usermod -a -G wheel "$username"
  export repodir="/home/$username/.local/src"
  mkdir -p "$repodir"
  #shellcheck disable=2016
echo '
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
' | tee -a "/home/$username/.profile" "/home/$username/.zshenv" "/home/$username/.bash_profile"
  chown -R "$username:$username" "/home/$username"
  passwd "$username"
}

makepkginstall() {
  # Installs $1 manually. Used only for AUR helper here.
  # Should be run after repodir is created and var is set.
  echo "Installing '$1'"
  dir="/home/$username/.local/src/$1"
  sudo -u "$username" mkdir -p "$dir"
  sudo -u "$username" git clone "https://aur.archlinux.org/$1.git" "$dir" > /dev/null 2>&1 \
    || {
      cd "$dir" || return 1
      sudo -u "$username" git pull --force origin master
    }
  sudo -u "$username" -D "$dir" makepkg --noconfirm -si > /dev/null 2>&1 || return 1
}


_log "This script should run in chrooted newly installed Arch system with generated fstab"
_log "Press RETURN to continue"
read -r

_log "Firstly, set password for root user"
passwd

# Check if user is root on Arch distro. Install curl and check internet connection
#shellcheck disable=2015
pacman --noconfirm --needed -Sy curl && curl example.com > /dev/null 2>&1 ||
  _error "Are you sure you're running this as the root user, are on an Arch-based distribution and have an internet connection?"

_log "Updating system"
pacman -Syu ||
  _error "System update failed"

_log "Refreshing Arch Keyring"
installpkg archlinux-keyring ||
  _error "Keyring update failed";

_log "Installing required packages"
installpkg curl base-devel git ntp zsh sudo ||
  _error "Install failed";

_log "Configuring locale"
echo "LANG=en_US.UTF-8" > /etc/locale.conf
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
ln -sf "/usr/share/zoneinfo/$bootstrap_timezone" /etc/localtime
locale-gen

_log "Configuring hostname"
echo "$bootstrap_hostname" > /etc/hostname
echo "# Static table lookup for hostnames.
# See hosts(5) for details.
127.0.0.1	  localhost
::1         localhost
127.0.1.1	  ${bootstrap_hostname}.localdomain	${bootstrap_hostname}" > /etc/hosts


_log "Synchronizing system time"
ntpdate 0.us.pool.ntp.org > /dev/null 2>&1 &&
  timedatectl set-ntp 1 &&
  hwclock --systohc

_log "Installing networkmanager"
installpkg networkmanager ||
  _error "Could not install networkmanager"
systemctl enable NetworkManager
systemctl enable NetworkManager-wait-online
systemctl start NetworkManager

_log "Adding user"
_add_user_with_pass ||
  _error "Could not add user"

# Allow user to run sudo without password. Since AUR programs must be installed
# in a fakeroot environment, this is required for all builds with AUR.
[ -f /etc/sudoers.pacnew ] && cp /etc/sudoers.pacnew /etc/sudoers # Just in case
echo "%wheel ALL=(ALL) NOPASSWD: ALL #REMOVE_THIS_LINE" >> /etc/sudoers


# Make pacman and paru colorful and adds eye candy on the progress bar because why not.
sed -i "
s~^#Color~Color~
s~^#VerbosePkgLists~VerbosePkgLists~
s~^#\?ParallelDownloads.*=.*$~ParallelDownloads = $(($(nproc) * 2))~
" /etc/pacman.conf
# if parallel downloads option is set, append one
grep -q "ParallelDownloads" /etc/pacman.conf || sed -i "/^VerbosePkgLists/a ParallelDownloads = $(($(nproc) * 2))" /etc/pacman.conf

# Use all cores for compilation.
sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf


# INSTALL PACKAGES
_log "Installing AUR helper - paru"
makepkginstall paru-bin ||
  _error "Failed to install AUR helper."

# Make zsh the default shell for the user.
chsh -s /bin/zsh "$username" > /dev/null 2>&1
sudo -u "$username" mkdir -p "/home/$username/.cache/zsh/"

_log "Initalizing chezmoi dotfiles"
installpkg chezmoi
sudo -u "$username" chezmoi init https://github.com/pavulonx/dots.git

# some cleanups
sed -i "/#REMOVE_THIS_LINE/d" /etc/sudoers

echo "All dome!"

_log "You can now install bootloader manually and you are ready to go"
