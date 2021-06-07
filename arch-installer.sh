#!/bin/bash

disk="/dev/sda"
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
WHITE='\033[0;37m'
NC='\033[0m'

printf "${CYAN}                _           _           _        _ _ 
  __ _ _ __ ___| |__       (_)_ __  ___| |_ __ _| | | ___ _ __ 
 / _\` | \'__/ __| \'_ \ _____| | \'_ \/ __| __/ _\` | | |/ _ \ \'__|
| (_| | | | (__| | | |_____| | | | \__ \ || (_| | | |  __/ |   
 \__,_|_|  \___|_| |_|     |_|_| |_|___/\__\__,_|_|_|\___|_|   

\t\t       ________________ 
\t\t      < i use arch btw >
\t\t       ---------------- 
\t\t         \\
\t\t          \\
\t\t              .--.
\t\t             |o_o |
\t\t             |:_/ |
\t\t            //   \\ \\
\t\t           (|     | )
\t\t          /\'\\_   _/\`\\
\t\t          \\___)=(___/




${WHITE}
"

format() {
	printf "\n${BLUE}[${WHITE}..${BLUE}] ext4 partition:${WHITE} $disk"
	read -r -n1 ext4
	printf "\n${BLUE}[${WHITE}..${BLUE}] swap partition:${WHITE} $disk"
	read -r -n1 swap
	
	printf "\n\n${NC}"
	mkfs.ext4 -F $disk$ext4
	mkswap $disk$swap
	swapon $disk$swap
}

printf "${BLUE}[${WHITE}+${BLUE}] setting the keyboard layout to ${GREEN}br-abnt2${BLUE}...\n\n"
loadkeys br-abnt2

printf "${BLUE}[${WHITE}..${BLUE}] generating mirrorlist...\n"
reflector -c Brazil -a 12 --sort rate --save /etc/pacman.d/mirrorlist >& /dev/null

while ! [ "$opt" = 'y' -o "$opt" = 'Y' -o "$opt" = 'n' -o "$opt" = 'N' ]
do
	printf "\n${BLUE}[${WHITE}?${BLUE}] is the disk pre-partitioned? ${GREEN}(y/n) ${BLUE}<--${WHITE} "
	read -r -n1 opt
done

if [[ "$opt" == 'y' ]] || [[ "$opt" == 'Y' ]]
then
	format
else
	fdisk $disk
	clear
	
	format
fi

printf "\n${BLUE}[${WHITE}+${BLUE}] mounting ${GREEN}$disk$ext4 ${BLUE}to /mnt\n\n"
mount $disk$ext4 /mnt

printf "${BLUE}[${WHITE}..${BLUE}] starting base packages installation\n${NC}"
pacstrap /mnt base linux linux-firmware vim intel-ucode xf86-video-intel

printf "\n${BLUE}[${WHITE}+${BLUE}] generating ${GREEN}fstab${NC}\n"
genfstab -U /mnt >> /mnt/etc/fstab

printf "\n${BLUE}[${WHITE}+${BLUE}] writing the other half of the script to /mnt\n\n"
cat << EOF > /mnt/arch-installer2.sh
#!/bin/bash

BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
WHITE='\033[0;37m'
NC='\033[0m'

get_pwd() {
	printf "\${BLUE}[\${WHITE}?\${BLUE}] password: "
	read -s -r pwd
	printf "\\n\${BLUE}[\${WHITE}?\${BLUE}] one more time: "
	read -s -r pwd2
}

printf "\\n\${BLUE}[\${WHITE}+\${BLUE}] adjusting timezone and locale\${NC}\\n"
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
timedatectl set-ntp true

sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

printf "\\n\${BLUE}[\${WHITE}+\${BLUE}] setting hostname and configuring \${GREEN}/etc/hosts"
echo "arch" > /etc/hostname
echo "KEYMAP=br-abnt2" > /etc/vconsole.conf
echo "127.0.0.1			localhost arch" >> /etc/hosts
echo "::1			localhost" >> /etc/hosts

printf "\\n\\n\${BLUE}[\${WHITE}+\${BLUE}] configuring \${GREEN}/etc/pacman.conf"
sed -i 's/#Color/Color/g' /etc/pacman.conf
sed -i 's/#VerbosePkgLists/VerbosePkgLists/g' /etc/pacman.conf

printf "\\n\\n\${BLUE}[\${WHITE}+\${BLUE}] installing \${PURPLE}BlackArch\${BLUE} repos\${NC}\\n"
curl https://blackarch.org/strap.sh | sh

while ! [ "\$i3" = 'y' -o "\$i3" = 'Y' -o "\$i3" = 'n' -o "\$i3" = 'N' ]
do
	printf "\\n\${BLUE}[\${WHITE}+\${BLUE}] install \${CYAN}i3\${BLUE}?\${GREEN} (y/n)\${BLUE} <--\${WHITE} "
	read -r -n1 i3
done

pkgs="base-devel dialog dosfstools firefox git grub gtop linux-headers mtools ncmpcpp neofetch net-tools 
netcat networkmanager mpd reflector terminator ttf-roboto-mono unzip wget wpa_supplicant zsh"
if [[ "\$i3" == 'y' ]] || [[ "\$i3" == 'Y' ]]
then
	pkgs+=' compton dunst i3-gaps i3blocks i3status lxappearance nitrogen pavucontrol-qt rofi scrot xorg xorg-xinit'
fi

printf "\\n\\n\${BLUE}[\${WHITE}+\${BLUE}] installing packages\${NC}\\n"
pacman -Syyyu --noconfirm \$pkgs

printf "\\n\${BLUE}[\${WHITE}..\${BLUE}] setting up user \${CYAN}blvckmetxl\\n"
useradd -mG wheel,audio,video blvckmetxl -s /usr/bin/zsh
sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers
curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O
sed -i 's/RUNZSH:-yes/RUNZSH:-no/g' install.sh
chmod +x install.sh
sudo -u blvckmetxl ./install.sh
rm install.sh
if [[ "\$i3" == 'y' ]] || [[ "\$i3" == 'Y' ]]
then
	echo "startx" > /home/blvckmetxl/.zlogin; chown blvckmetxl:blvckmetxl /home/blvckmetxl/.zlogin
	echo "exec i3" > /home/blvckmetxl/.xinitrc; chown blvckmetxl:blvckmetxl /home/blvckmetxl/.xinitrc
fi

test=0
while [ -z "\$pwd" ]
do
	if [ "\$test" -gt 0 ]
	then
		printf "\\n\\n\${BLUE}[\${WHITE}-\${BLUE}] try again.\\n"
	fi
	get_pwd
	
	if [ "\$pwd" == "\$pwd2" ]
	then
		echo "blvckmetxl:\$pwd" | chpasswd
	else	
		let "test+=1"
		pwd=
	fi
done

printf "\\n\\n\${BLUE}[\${WHITE}+\${BLUE}] installing and setting up grub\${NC}\\n"
grub-install $disk
grub-mkconfig -o /boot/grub/grub.cfg

printf "\\n\${BLUE}[\${WHITE}+\${BLUE}] enabling NetworkManager\${NC}\\n"
systemctl enable NetworkManager

printf "\\n\${BLUE}[\${WHITE}+\${BLUE}] exiting."
exit
EOF
chmod +x /mnt/arch-installer2.sh

printf "${BLUE}[${WHITE}+${BLUE}] chrooting into the fresh ${CYAN}arch ${BLUE}installation${NC}\n"
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
arch-chroot /mnt ./arch-installer2.sh

rm /mnt/arch-installer2.sh
printf "\n\n${BLUE}[${WHITE}+${BLUE}] system successfully installed. reboot? ${GREEN}(y/n) ${BLUE}<--${WHITE} "
while ! [ "$rb" = 'y' -o "$rb" = 'Y' -o "$rb" = 'n' -o "$rb" = 'N' ]
do
	read -r -n1 rb
done

if [[ "$rb" == 'y' ]] || [[ "$rb" == 'Y' ]]
then
	umount /mnt
	reboot
else
	printf "\n\n${NC}"
	exit
fi
