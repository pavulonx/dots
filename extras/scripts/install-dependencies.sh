#!/bin/bash
#set -e

install_all() {
	echo "$*" | xargs paru -S --needed
}

core=(
bat
chezmoi
git-delta
dust
exa
fd
fzf
git
htop
jq
lf
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
zip
zsh
zsh-completions
)
echo "Installing core"
install_all "${core[@]}"


gui=(
adwaita-icon-theme
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
networkmanager_dmenu
picom
polybar
redshift
rofi
scrot
thunar
thunar-archive-plugin
thunar-volmanudiskie
ueberzug
unclutter
xautomation
xbindkeys
xclip
xdg-user-dirs
xdg-utils
xdotool
xmonad
xmonad-contrib
xmonad-utils
xorg-xkill
xsel
xss-lock
)
echo "Installing minimal gui"
install_all "${gui[@]}"


sound=(
pamixer
pavucontrol
pipewire
pipewire-media-session
pipewire-pulse
playerctl
)
echo "Installing sound packages"
install_all "${sound[@]}"


printer=(
cups
cups-pdf
ghostscript
gsfonts
libcups
system-config-printer
)
echo "Installing printer packages"
install_all "${printer[@]}"


fonts=(
adobe-source-sans-pro-fonts
awesome-terminal-fonts
cantarell-fonts
nerd-fonts-complete
noto-fonts
noto-fonts-emoji
noto-fonts-extra
ttf-droid
ttf-font-awesome
ttf-hack
ttf-inconsolata
ttf-jetbrains-mono
ttf-lato
ttf-liberation
ttf-roboto
)
echo "Installing fonts packages"
install_all "${fonts[@]}"


programs=(
brave-beta-bin
evince
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
spotify
sxiv
system-config-printer
transmission-cli
zathura
)
echo "Installing programs packages"
install_all "${programs[@]}"


read -p "Install laptop dependencies? [y/N] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  laptop=(
  tlp
  )

  echo "Installing laptop packages"
  install_all "${laptop[@]}"

  echo "Post install inits"

  echo "Enabling tlp.service"
  sudo systemctl enable tlp.service

fi

echo "LAPTOP"

read -p "Install bluetooth dependencies? [y/N] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then

  bluetooth=(
  pulseaudio-bluetooth
  bluez
  bluez-libs
  bluez-utils
  )

  echo "Installing bluetooth packages"
  install_all "${bluetooth[@]}"

  echo "Post install inits"

  echo "Enabling bluetooth.service"
  sudo systemctl enable bluetooth.service
  sudo systemctl start bluetooth.service
  sudo sed -i 's/'#AutoEnable=false'/'AutoEnable=true'/g' /etc/bluetooth/main.conf

fi

printf "\n\nCOMPLETED!\n\n"

exit 0
#installation for openrc
#openrc-zsh-completions
