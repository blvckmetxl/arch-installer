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

sleep 1

pacman -S base-devel >& /dev/null
git clone https://aur.archlinux.org/yay.git
chown bm:bm -R yay
cd yay && sudo -u bm makepkg -si
cd .. && rm -rf yay

sleep 1

git clone https://github.com/klange/nyancat.git
chown bm:bm -R nyancat
cd nyancat && sudo -u bm make && mv src/nyancat /usr/bin
cd .. && rm -rf nyancat

sleep 1

pacman -Qs zsh >& /dev/null
if [ "$?" -ne 0 ]
then
	pacman -S zsh
fi

[ ! -d "/home/bm/.oh-my-zsh" ] && curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O && sed -i 's/RUNZSH=${RUNZSH:-yes}/RUNZSH=${RUNZSH:-no}/g' install.sh && chmod +x install.sh && chown bm:bm install.sh && sudo -u bm ./install.sh && rm install.sh
mv bm.zsh-theme /home/bm/.oh-my-zsh/custom/themes
mv .zshrc /home/bm

mv wallpapers /home/bm
mv scripts /home/bm
chmod +x /home/bm/scripts/chwp.sh /home/bm/scripts/tg.sh
echo 1 > /home/bm/scripts/gc
chown bm:bm /home/bm/scripts/gc
mkdir /home/bm/screenshots
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

pacman -Qs picom >& /dev/null
if [ "$?" -ne 0 ]
then
	pacman -S picom
	chown root:root picom.conf
	mv picom.conf /etc/xdg/picom.conf
fi

echo "_JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on'" >> /etc/environment # fix burpsuite weird font

if [ ! -d "/home/bm/.config" ]
then
	mv .config /home/bm
else
	rm -rf /home/bm/.config/i3 2>/dev/null
	rm -rf /home/bm/.config/rofi 2>/dev/null
	rm -rf /home/bm/.config/alacritty 2>/dev/null
	mv .config/* /home/bm/.config
fi

pacman -S --noconfirm firefox ripgrep alacritty xterm unzip tcpdump wget dialog i3-gaps rofi xcursor-simpleandsoft hicolor-icon-theme lxappearance-gtk3 xorg-server thunar discord openvpn feh scrot gparted reflector tk lightdm lightdm-gtk-greeter python2 cronie pkgfile libpulse noto-fonts noto-fonts-cjk noto-fonts-emoji pulseaudio libpulse python-pip xdg-utils gvfs gvfs-afc # needed for thunar to show my usb
sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf # fix pulseaudio config
sed -i 's/\/usr\/bin\/gparted/\/usr\/bin\/sudo \/usr\/bin\/gparted/g' /usr/share/applications/gparted.desktop # workaround not running polkit
chown root:root solarized-darker.rasi
mv solarized-darker.rasi /usr/share/rofi/themes
echo "* * * * * root /usr/bin/pkgfile --update" >> /etc/cron.d/0hourly
mkdir -p /home/bm/.icons/default && chown -R bm:bm /home/bm/.icons
echo -e "[Icon Theme]\nName=Default\nComment=Default Cursor Theme\nInherits=Simple-and-Soft" > /home/bm/.icons/default/index.theme
chown bm:bm /home/bm/.icons/default/index.theme
ln -s /usr/share/icons/Simple-and-Soft/cursors /home/bm/.icons/default/cursors
curl -O https://raw.githubusercontent.com/jluttine/rofi-power-menu/master/rofi-power-menu && chmod +x rofi-power-menu
sed -i 's/all=(shutdown reboot suspend hibernate logout lockscreen)/all=(shutdown reboot logout suspend)/g' rofi-power-menu && mv rofi-power-menu /usr/bin
systemctl enable lightdm
systemctl enable --now cronie

sudo -u bm yay -S bumblebee-status neovim nerd-fonts-mononoki suru-plus-git

sudo -u bm yay --nopgpfetch --mflags --skipinteg spotify spotify-adblock tor-browser
chown root:root spotify.desktop
mv spotify.desktop /usr/share/applications
rm /usr/share/applications/spotify-adblock.desktop

pip install dbus-python # needed for bumblebee-status spotify module

curl https://blackarch.org/strap.sh | sh
sudo kill -9 `pidof pulseaudio` && pulseaudio
