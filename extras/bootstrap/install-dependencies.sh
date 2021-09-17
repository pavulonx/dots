#!/usr/bin/env bash

set -euo pipefail

_install() {
  paru -S --needed "$@"
}

_log_install() {
  pad='─────────────────────────────────────────────────────────────────────────────'
  num="$*"; num="${#num}"
  sep="${pad:0:${num}}"
  echo ''
  echo "$sep"
  printf '\e[0;32;1m%s\e[0m\n' "$*"
  echo "$sep"
}

if readlink /sbin/init 2>/dev/null | grep -q openrc; then
  initsys=openrc
elif grep -q 'systemd' /proc/1/comm; then
  initsys=systemd
fi

_log_install "Installing core"
core=(
#  arch-install-scripts
  bat
  chezmoi
  git
  git-delta
  dust
  exa
  fd
  fzf
  git
  htop
  jq
  lf-bin
  lua
  moreutils
  neofetch
  neovim
  openssh
  pacman-contrib
  polkit
  psmisc
  ranger
  ripgrep
  shellcheck
  tealdeer
  tree
  tumbler
  unzip
  w3m
  zip
  zsh
  zsh-completions
)
_install "${core[@]}"


_log_install "Installing minimal gui"
gui=(
  adwaita-icon-theme
  alacritty
  arandr
  autorandr
  clipmenu
  dunst
  feh
  flatery-icon-theme-git
  gsimplecal
  i3-gaps
  i3lock-color-git
  lxappearance
  maim
  mate-polkit
  network-manager-applet
  networkmanager-dmenu-git
  picom
  polybar
  redshift
  rofi
  scrot
  thunar
  thunar-archive-plugin
  thunar-volman
  udiskie
  ueberzug
  unclutter
  xautomation
  xbindkeys
  xclip
  xdg-utils
  xdotool
  xmonad
  xmonad-contrib
  xmonad-utils
  xorg
  xorg-xinit
  xorg-xkill
  xsel
  xss-lock
  xterm
)
_install "${gui[@]}"


_log_install "Installing sound packages"
sound=(
  pamixer
  pavucontrol
  pipewire
  pipewire-media-session
  pipewire-pulse
  playerctl
)
_install "${sound[@]}"




_log_install "Installing fonts packages"
fonts=(
  adobe-source-sans-pro-fonts
  awesome-terminal-fonts
  cantarell-fonts
  nerd-fonts-complete
  noto-fonts
  noto-fonts-emoji
  noto-fonts-extra
  ttf-dejavu
  ttf-droid
  ttf-font-awesome
  ttf-hack
  ttf-inconsolata
  ttf-jetbrains-mono
  ttf-lato
  ttf-liberation
  ttf-roboto
)
_install "${fonts[@]}"


programs=(
  brave-beta-bin
  file-roller
  firefox-developer-edition
  gimp
  gnome-calculator
  gparted
  gpick
  gucharmap
  mpv
  peek
  solaar-git
  sxiv
  transmission-cli
  youtube-dl
  zathura
)
_log_install "Installing programs packages"
_install "${programs[@]}"



printf "\nInstall printers packages? [y/N]: "
read -r REPLY
if [[ $REPLY =~ ^[Yy]$ ]]; then
  _log_install "Installing printer packages"
  printer=(cups cups-pdf ghostscript gsfonts libcups system-config-printer)
  _install "${printer[@]}"
fi



printf "\nInstall laptop dependencies? [y/N]: "
read -r REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  laptop=(tlp tlpui acpi acpid acpi_call)

  _log_install "Installing laptop packages"
  _install "${laptop[@]}"

  if [[ "$initsys" == "openrc" ]]; then
    _install "tlp-openrc"
    echo "You can now enable tlp-openrc service"
  elif [[ "$initsys" == "systemd" ]]; then
    echo "Enabling tlp.service"
    sudo systemctl enable tlp.service
  fi
  echo "See https://wiki.archlinux.org/title/TLP for further configuration"
  echo " (e.g. ThinkPad specific battery settings)"
fi


printf "\ninstall bluetooth packages? [y/N]: "
read -r reply
if [[ "$reply" =~ ^[yy]$ ]]; then

  bluetooth=(bluez bluez-libs bluez-utils blueman)
  _log_install "Installing bluetooth"
  _install "${bluetooth[@]}"

  echo "Post install inits"
  if [[ "$initsys" == "openrc" ]]; then
    echo "You can now enable bluetooth services service in openrc"
  elif [[ "$initsys" == "systemd" ]]; then
    echo "Enabling bluetooth.service"
    sudo systemctl enable bluetooth.service
    sudo systemctl start bluetooth.service
    sudo sed -i 's/'#AutoEnable=false'/'AutoEnable=true'/g' /etc/bluetooth/main.conf
  fi
fi


if [[ "$initsys" == "openrc" ]]; then
  openrc=(openrc-zsh-completions)
  _log_install "Installing openrc addons"
  _install "${openrc[@]}"
fi

printf "\nInstalation complete!\n"
