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
	printf "\n${BLUE}[${WHITE}?${BLUE}] ext4 partition:${WHITE} $disk"
	read -r -n1 ext4
	printf "\n${BLUE}[${WHITE}?${BLUE}] swap partition:${WHITE} $disk"
	read -r -n1 swap
	
	printf "\n\n"
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
	printf "\n${BLUE}[${WHITE}?${BLUE}] is the disk pre-partitioned? (y/n) <-- "
	read -rsn1 opt
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

printf "${BLUE}[${WHITE}+${BLUE}] starting base packages installation\n\n"
pacstrap /mnt base linux linux-firmware vim intel-ucode xf86-video-intel

printf "${BLUE}[${WHITE}+${BLUE}] generating ${GREEN}fstab\n\n"
genfstab -U /mnt >> /mnt/etc/fstab

printf "${BLUE}[${WHITE}+${BLUE}] writing the other half of the script to /mnt\n\n"
cat << EOF > test.test.test
#!/bin/bash

ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
timedatectl set-ntp true

sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=br-abnt2" > /etc/vconsole.conf
echo "arch" > /etc/hostname
echo "127.0.0.1		localhost arch" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts

read -r -p "${BLUE}[${WHITE}+${BLUE}] password: " pwd
useradd -mG wheel,audio,video blvckmetxl
echo "root:\$pwd" | chpasswd
echo "blvckmetxl:\$pwd" | chpasswd

pacman -S grub networkmanager zsh reflector wget git net-tools iwctl base-devel dosfstools mtools dialog wireless_tools wpa_supplicant linux-headers

grub-install $disk
grub-mkconfig -o /boot/grub/grub.cfg
EOF
chmod +x /mnt/arch-installer2.sh

printf "${BLUE}[${WHITE}+${BLUE}] chrooting into the fresh ${CYAN}arch ${BLUE}installation\n\n"
arch-chroot /mnt ./arch-installer2.sh

clear
printf "${BLUE}[${WHITE}+${BLUE}]${CYAN} rebooting"
reboot
