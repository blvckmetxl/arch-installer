#!/bin/bash

if [ "$EUID" -ne 0 ]
then
	echo "not root"
	exit
fi

ping -c 1 -W 1 archlinux.org >& /dev/null
if [ "$?" -ne 0 ]
then
	echo "no internet"
	read -r -p "open NMTUI? (y/n) " x

	case $x in
		[Yy]* ) nmtui;;
		* ) exit;;
	esac
fi

pacman -Qs base-devel >& /dev/null
if [ "$?" -ne 0 ]
then
	pacman -S base-devel
fi

git clone https://aur.archlinux.org/yay.git
cd yay && sudo -u bm makepkg -si
cd .. && rm -rf yay

git clone https://github.com/klange/nyancat.git
cd nyancat && make && cd src && mv nyancat /usr/bin
cd .. && rm -rf nyancat

[ "$PWD" != "$HOME/stuff" ] && cd $HOME/stuff

pacman -Qs zsh >& /dev/null
if [ "$?" -ne 0 ]
then
	pacman -S zsh
fi
[ ! -d "$HOME/.oh-my-zsh" ] && curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O && sed -i 's/RUNZSH=${RUNZSH:-yes}/RUNZSH=${RUNZSH:-no}/g' install.sh && chmod +x install.sh && ./install.sh && rm install.sh
mv bm.zsh-theme $HOME/.oh-my-zsh/custom/themes
mv .zshrc $HOME

mv wallpapers $HOME
mv scripts $HOME
echo 1 > $HOME/scripts/gc
mkdir $HOME/screenshots

pacman -Qs picom >& /dev/null
if [ "$?" -ne 0 ]
then
	pacman -S picom
	mv picom.conf /etc/xdg/picom.conf
fi

echo "_JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on'" >> /etc/environment

if [ ! -d "$HOME/.config" ]
then
	mv .config $HOME
else
	rm -rf $HOME/.config/i3 2>/dev/null
	rm -rf $HOME/.config/rofi 2>/dev/null
	rm -rf $HOME/.config/alacritty 2>/dev/null
	mv .config/* $HOME/.config
fi

pacman -S --noconfirm firefox alacritty xterm unzip wget dialog i3-gaps rofi xorg-server pcmanfm discord openvpn feh scrot gparted reflector
mv solarized-darker.rasi /usr/share/rofi/themes

yay -S bumblebee-status spotify-adblock
yay --mflags --skipinteg spotify
mv spotify.desktop /usr/share/applications
rm /usr/share/applications/spotify-adblock.desktop
