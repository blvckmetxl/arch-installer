#!/bin/bash

disk="/dev/sda"
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
WHITE='\033[0;37m'
NC='\033[0m

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
	printf "\n"
	printf "\n${BLUE}[${WHITE}?${BLUE}] ext4 partition:${WHITE} $disk"
	read -r -n1 ext4
	printf "\n${BLUE}[${WHITE}?${BLUE}] swap partition:${WHITE} $disk"
	read -r -n1 swap
	
	printf "\n${CYAN}"
	mkfs.ext4 $disk$ext4
	mkswap $disk$swap
	swapon $disk$swap
}

printf "${BLUE}[${WHITE}+${BLUE}] setting the keyboard layout to ${GREEN}br-abnt2...\n\n"
loadkeys br-abnt2

printf "${BLUE}[${WHITE}+${BLUE}] generating mirrorlist...\n"
reflector -c Brazil -a 12 --sort rate --save /etc/pacman.d/mirrorlist >& /dev/null

while ! [ "$opt" = 'y' -o "$opt" = 'Y' -o "$opt" = 'n' -o "$opt" = 'N' ]
do
	printf "\n${BLUE}[${WHITE}?${BLUE}] is the disk pre-partitioned? ${GREEN}(y/n) ${CYAN}<-- "
	read -r n1 opt
done

if [[ "$opt" == 'y' ]] || [[ "$opt" == 'Y' ]]
then
	format
else
	fdisk $disk
	clear
	
	format
fi

printf "${BLUE}[${WHITE}+${BLUE}] mounting ${GREEN}$disk$ext4 ${BLUE}to /mnt\n\n"
mount $disk$ext4 /mnt

printf "${BLUE}[${WHITE}+${BLUE}] starting base packages installation\n\n${CYAN}"
pacstrap /mnt base linux linux-firmware vim intel-ucode xf86-video-intel

printf "${BLUE}[${WHITE}+${BLUE}] generating ${GREEN}fstab\n\n"
genfstab -U /mnt >> /mnt/etc/fstab

printf "${BLUE}[${WHITE}+${BLUE}] writing the other half of the script to /mnt\n\n"
cat << EOF > /mnt/arch-installer2.sh
#!/bin/bash

BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
WHITE='\033[0;37m'

printf "\${BLUE}[\${WHITE}+\${BLUE}] adjusting timezone and locale\${CYAN}"
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
timedatectl set-ntp true

sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=br-abnt2" > /etc/vconsole.conf

printf "\${BLUE}[\${WHITE}+\${BLUE}] setting hostname and configuring \${GREEN}/etc/hosts"
echo "arch" > /etc/hostname
echo "127.0.0.1			localhost arch" >> /etc/hosts
echo "::1			localhost" >> /etc/hosts

printf "\${BLUE}[\${WHITE}?\${BLUE}] adding user \${CYAN}blvckmetxl"
printf "\${BLUE}[\${WHITE}?\${BLUE}] password:\${CYAN} "
read -r pwd
useradd -mG wheel,audio,video blvckmetxl
echo "blvckmetxl:\$pwd" | chpasswd
sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

printf "\${BLUE}[\${WHITE}+\${BLUE}] install some more packages\${CYAN}"
pacman -S base-devel dialog dosfstools git grub iwd linux-headers mtools net-tools networkmanager reflector terminator wireless_tools wget wpa_supplicant xorg zsh

printf "\${BLUE}[\${WHITE}+\${BLUE}] installing and setting up grub\${CYAN}"
grub-install $disk
grub-mkconfig -o /boot/grub/grub.cfg

clear
printf "\${BLUE}[\${WHITE}+\${BLUE}] \${CYAN}exiting."
exit
EOF
chmod +x /mnt/arch-installer2.sh

printf "${BLUE}[${WHITE}+${BLUE}] chrooting into the fresh ${CYAN}arch ${BLUE}installation\n\n"
arch-chroot /mnt ./arch-installer2.sh

printf "${BLUE}[${WHITE}+${BLUE}]${CYAN} reboot? ${GREEN}(y/n) ${CYAN}<-- "
while ! [ "$rb" = 'y' -o "$rb" = 'Y' -o "$rb" = 'n' -o "$rb" = 'N' ]
do
	read -r -n1 rb
done

if [[ "$rb" == 'y' ]] || [[ "$rb" == 'Y' ]]
then
	reboot
else
	printf "\n${NC}"
	exit
fi
