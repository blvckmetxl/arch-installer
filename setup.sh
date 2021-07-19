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

sed -i "s/#Color/Color/g" /etc/pacman.conf
sed -i "s/#VerbosePkgLists/VerbosePkgLists/g" /etc/pacman.conf
sed -i "s/#ParallelDownloads/ParallelDownloads/g" /etc/pacman.conf

pacman -S base-devel >& /dev/null
git clone https://aur.archlinux.org/yay.git
chown bm:bm -R yay
cd yay && sudo -u bm makepkg -si
cd .. && rm -rf yay
sudo pacman -Rns go

git clone https://github.com/klange/nyancat.git
chown bm:bm -R nyancat
cd nyancat && sudo -u bm make && mv src/nyancat /usr/bin
cd .. && rm -rf nyancat

pacman -Qs zsh >& /dev/null
if [ "$?" -ne 0 ]
then
	pacman -S zsh
fi

[ ! -d "/home/bm/.oh-my-zsh" ] && curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O && sed -i 's/RUNZSH=${RUNZSH:-yes}/RUNZSH=${RUNZSH:-no}/g' install.sh && chmod +x install.sh && chown bm:bm install.sh && sudo -u bm ./install.sh && rm install.sh
mv bm.zsh-theme /home/bm/.oh-my-zsh/custom/themes
mv .zshrc /home/bm

mv wallpapers /home/bm
mkdir /home/bm/vpns
mkdir /opt/wordlists
wget https://github.com/praetorian-inc/Hob0Rules/raw/master/wordlists/rockyou.txt.gz
gzip -d rockyou.txt.gz
mv rockyou.txt /opt/wordlists
curl -O https://raw.githubusercontent.com/daviddias/node-dirbuster/master/lists/directory-list-2.3-medium.txt
mv directory-list-2.3-medium.txt /opt/wordlists
mkdir /etc/feroxbuster
echo -e "wordlist = \"/opt/wordlists/directory-list-2.3-medium.txt\"\nthreads = 10\nsave_state = false" > /etc/feroxbuster/ferox-config.toml
mkdir /etc/samba
touch /etc/samba/smb.conf
chown bm:bm /home/bm/screenshots
mv wallpapers /home/bm

pacman -Qs picom >& /dev/null
if [ "$?" -ne 0 ]
then
	pacman -S picom
fi

echo "_JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on'" >> /etc/environment # fix burpsuite weird font
echo "setxkbmap br" >> /home/bm/.profile
chown bm:bm /home/bm/.profile

rm -rf /home/bm/.config 2>/dev/null
mv .config /home/bm

dir=$(pwd)
cd /home/bm/.config
chmod +x bspwm/bspwmrc polybar/launch.sh polybar/mic.sh
cd $dir

pacman -S --noconfirm firefox ripgrep netcat alacritty unzip tcpdump flameshot xorg-xsetroot wget dialog sxhkd bspwm qbittorrent awesome-terminal-fonts arandr vlc rofi xcursor-simpleandsoft lxappearance-gtk3 xorg-server thunar discord openvpn feh flameshoburpburpt gparted reflector lightdm rlwrap lightdm-gtk-greeter pkgfile noto-fonts noto-fonts-cjk noto-fonts-emoji pulseaudio python-pip xdg-utils gvfs gvfs-afc xsel

sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf # fix pulseaudio config
sed -i 's/\/usr\/bin\/gparted/\/usr\/bin\/sudo \/usr\/bin\/gparted/g' /usr/share/applications/gparted.desktop
mkdir -p /home/bm/.icons/default && chown -R bm:bm /home/bm/.icons
echo -e "[Icon Theme]\nName=Default\nComment=Default Cursor Theme\nInherits=Simple-and-Soft" > /home/bm/.icons/default/index.theme
chown bm:bm /home/bm/.icons/default/index.theme
systemctl enable lightdm

sudo -u bm yay -S --noconfirm --removemake neovim nerd-fonts-mononoki suru-plus-git polybar

sudo -u bm yay -S --noconfirm --removemake --nopgpfetch --mflags --skipinteg spotify spotify-adblock tor-browser
chown root:root spotify.desktop
mv spotify.desktop /usr/share/applications
rm /usr/share/applications/spotify-adblock.desktop
