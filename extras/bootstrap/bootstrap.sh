#!/bin/sh
# Debloated version of LARBS by Luke Smith <luke@lukesmith.xyz>
# License: GNU GPLv3

### OPTIONS AND VARIABLES ###
[ -z "$aurhelper" ] && aurhelper="${aurhelper:-paru}"
[ -z "$dotfilesrepo" ] && dotfilesrepo="https://github.com/lukesmithxyz/voidrice.git"
is_laptop="${is_laptop:-true}"

while getopts ":p:h" o; do case "${o}" in
  h) printf "Optional arguments for custom use:\\n  -r: Dotfiles repository (local file or url)\\n  -p: Dependencies and programs csv (local file or url)\\n  -a: AUR helper (must have pacman-like syntax)\\n  -h: Show this message\\n" && exit 1 ;;
  p) progsfile=${OPTARG} ;;
  *) printf "Invalid option: -%s\\n" "$OPTARG" && exit 1 ;;
esac done

[ -z "$progsfile" ] && progsfile="https://raw.githubusercontent.com/LukeSmithxyz/LARBS/master/progs.csv"

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
  chown -R "$username:$username" "/home/$username"
  passwd "$username"
}

makepkginstall() { # Installs $1 manually. Used only for AUR helper here.
  # Should be run after repodir is created and var is set.
  echo "Installing \"$1\", an AUR helper..."
  dir="$repodir/$1"
  sudo -u "$username" mkdir -p "$dir"
  sudo -u "$username" git clone "https://aur.archlinux.org/$1.git" "$dir" > /dev/null 2>&1 \
    || {
      cd "$dir" || return 1
      sudo -u "$username" git pull --force origin master
    }
  #cd "$dir" || exit 1
  sudo -u "$username" -D "$dir" makepkg --noconfirm -si > /dev/null 2>&1 || return 1
  #cd - || exit 1
}

maininstall() { # Installs all needed programs from main repo.
  echo "Installing \`$1\` ($n of $total). $1 $2"
  installpkg "$1"
}

gitmakeinstall() {
  progname="$(basename "$1" .git)"
  dir="$repodir/$progname"
  echo "Installing \`$progname\` ($n of $total) via \`git\` and \`make\`. $(basename "$1") $2"
  sudo -u "$username" git clone "$1" "$dir" > /dev/null 2>&1 \
    || {
      cd "$dir" || return 1
      sudo -u "$username" git pull --force origin master
    }
  cd "$dir" || exit 1
  make > /dev/null 2>&1
  make install > /dev/null 2>&1
  cd - || exit 1
}

aurinstall() {
  echo "Installing \`$1\` ($n of $total) from the AUR. $1 $2"
  echo "$aurinstalled" | grep -q "^$1$" && return 1
  sudo -u "$username" \
    XDG_CACHE_HOME="/home/$username/.cache" \
    XDG_CONFIG_HOME="/home/$username/.config" \
    XDG_DATA_HOME="/home/$username/.local/share" \
    "$aurhelper" -S --noconfirm "$1" > /dev/null 2>&1
}

installationloop() {
  ([ -f "$progsfile" ] && cp "$progsfile" /tmp/progs.csv) || curl -Ls "$progsfile" | sed '/^#/d' > /tmp/progs.csv
  total=$(wc -l < /tmp/progs.csv)
  aurinstalled=$(pacman -Qqm)
  while IFS=, read -r tag program comment; do
    n=$((n + 1))
    echo "$comment" | grep -q "^\".*\"$" && comment="$(echo "$comment" | sed "s/\(^\"\|\"$\)//g")"
    case "$tag" in
      "A") aurinstall "$program" "$comment" ;;
      "G") gitmakeinstall "$program" "$comment" ;;
      *) maininstall "$program" "$comment" ;;
    esac
  done < /tmp/progs.csv
}

chezmoi_init() {
  :
}

### THE ACTUAL SCRIPT ###

### This is how everything happens in an intuitive format and order.

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

_log "Adding user"
_add_user_with_pass ||
  _error "Could not add user"

_log "Synchronizing system time"
ntpdate 0.us.pool.ntp.org > /dev/null 2>&1 &&
  timedatectl set-ntp 1

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

# The command that does all the installing. Reads the progs.csv file and
# installs each needed program the way required. Be sure to run this only after
# the user has been created and has priviledges to run sudo without a password
# and all build dependencies are installed.
installationloop

# Make zsh the default shell for the user.
chsh -s /bin/zsh "$username" > /dev/null 2>&1
sudo -u "$username" mkdir -p "/home/$username/.cache/zsh/"

### laptop specific settings

# Tap to click
$is_laptop && [ ! -f /etc/X11/xorg.conf.d/30-touchpad.conf ] && printf 'Section "InputClass"
    Identifier "libinput touchpad catchall"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    # Enable left mouse button by tapping
  Option "Tapping" "on"
EndSection' > /etc/X11/xorg.conf.d/30-touchpad.conf

# some cleanups
sed -i "/#REMOVE_THIS_LINE/d" /etc/sudoers

echo "All dome!"
