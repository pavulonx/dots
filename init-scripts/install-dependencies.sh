#!/bin/bash
#set -e

install_all() {
	yay -S --noconfirm "$(yay -Qi $@ 2>&1 >/dev/null | grep "error: package" | grep "was not found" | cut -d"'" -f2 | tr "\n" " ")"
}

###############################################################################
echo "CORE"
core=(
adapta-gtk-theme
adwaita-icon-theme
arandr
autorandr
betterlockscreen
clipit
feh
flat-remix
flat-remix-gtk
i3-gaps
i3lock-color
i3-scrot #aur
i3status
imagemagick
lightdm
lxappearance
picom
playerctl
polybar
redshift
geoclue
rofi
scrot
thunar
thunar-archive-plugin
thunar-volman
volumeicon
xautomation
xclip
xdotool
xf86-input-evdev
xf86-input-libinput
xf86-input-void
xfce4-power-manager
zsh
chezmoi
polkit
)

echo "Installing core packages"
install_all "${core[@]}"

echo "Post install scripts"

echo "Enabling lightdm as display manager"
sudo systemctl enable lightdm.service -f

###############################################################################
echo "SOUND"
sound=(
pulseaudio
pulseaudio-alsa
pavucontrol
alsa-firmware
alsa-lib
alsa-plugins
alsa-utils
gstreamer
gst-plugins-good
gst-plugins-bad
gst-plugins-base
gst-plugins-ugly
playerctl
volumeicon
)

echo "Installing sound packages"
install_all "${sound[@]}"

###############################################################################
echo "NETWORK"
network=(
avahi
)

echo "Installing network packages"
install_all "${network[@]}"

echo "Post install scripts"

echo "Enabling avahi-daemon"
sudo systemctl enable avahi-daemon.service

###############################################################################
echo "PRINTERS"
printer=(
cups
cups-pdf
ghostscript
gsfonts
gutenprint
libcups
system-config-printer
)

echo "Installing printer packages"
install_all "${printer[@]}"

echo "Post install scripts"

echo "Enabling org.cups.cupsd.service"
sudo systemctl enable org.cups.cupsd.service

###############################################################################
echo "TOOLS"
tools=(
xdg-utils
xdg-user-dirs
ripgrep
fzf
fd
inxi
#hblock
# bmenu # not available in arch
### archives
unace
unrar
zip
unzip
sharutils
uudeview
arj
cabextract
file-roller
xarchiver
)

echo "Installing tools packages"
install_all "${tools[@]}"

###############################################################################
echo "FONTS"
fonts=(
awesome-terminal-fonts
adobe-source-sans-pro-fonts
cantarell-fonts
noto-fonts
consolas-font
ttf-windows
nerd-fonts-dejavu-complete
nerd-fonts-terminus
terminus-font
ttf-bitstream-vera
ttf-dejavu
ttf-droid
ttf-hack
ttf-inconsolata
ttf-liberation
ttf-roboto
)

echo "Installing fonts packages"
install_all "${fonts[@]}"

###############################################################################
echo "PROGRAMS"
programs=(
gimp
inkscape
chromium
deluge
vlc
spotify
evince
gedit
peek
)

echo "Installing programs packages"
install_all "${programs[@]}"


###############################################################################
echo "LAPTOP"

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

###############################################################################
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

###############################################################################

printf "\n\nCOMPLETED!\n\n"
