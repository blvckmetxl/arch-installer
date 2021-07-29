#!/bin/bash

rm -rf /home/bm/Music
mv sxhkdrc /home/bm/.config/sxhkd/
mv config /home/bm/.config/bspwm/polybar/
mv .zshrc /home/bm/ && chmod +x /home/bm/.zshrc
mv .fehbg /home/bm/ && chmod +x /home/bm/.fehbg
mv bspwmrc /home/bm/.config/bspwm/ && chmod +x /home/bm/.config/bspwm/bspwmrc

mkdir /opt/wordlists
wget https://github.com/praetorian-inc/Hob0Rules/raw/master/wordlists/rockyou.txt.gz
gzip -d rockyou.txt.gz
mv rockyou.txt /opt/wordlists
curl -O https://raw.githubusercontent.com/daviddias/node-dirbuster/master/lists/directory-list-2.3-medium.txt
mv directory-list-2.3-medium.txt /opt/wordlists
mkdir /etc/feroxbuster
echo -e "wordlist = \"/opt/wordlists/directory-list-2.3-medium.txt\"\nthreads = 10\nsave_state = false" > /etc/feroxbuster/ferox-config.toml

pacman -Syyyu --noconfirm
pacman -S --noconfirm firefox discord ripgrep tcpdump python-pip qbittorrent xcursor-simpleandsoft pkgfile xorg-xsetroot
### tools ###
pacman -S --noconfirm aircrack-ng exploitdb hydra john metasploit wireshark-qt
sudo -u bm yay -S --noconfirm --mflags burpsuite feroxbuster rustscan wfuzz 
###   -   ###
sudo -u bm yay -S --noconfirm --removemake neovim spotify spotify-adblock tor-browser teams-for-linux
pkgfile --update

mkdir -p /home/bm/.icons/default 
echo -e "[Icon Theme]\nName=Default\nComment=Default Cursor Theme\nInherits=Simple-and-Soft" > /home/bm/.icons/default/index.theme
chown -R bm:bm /home/bm/.icons
sed -i 's/Inherits.*/Inherits=Simple-and-Soft/g' /usr/share/icons/default/index.theme
echo "gtk-cursor-theme-name=Simple-and-Soft" >> /usr/share/gtk-3.0/settings.ini
    
echo -e "JAVA_AWT_WM_NONREPARENTING=1" >> /etc/environment
