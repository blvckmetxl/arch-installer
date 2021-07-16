#!/bin/bash

ping -c 1 -W 1 archlinux.org >& /dev/null
if [ "$?" -ne 0 ]
then
	echo "no internet connectivity"
	exit 1
fi

loadkeys br-abnt2

timedatectl set-timezone America/Sao_Paulo
sleep 1

reflector -c Brazil -a 6 --sort rate --save /etc/pacman.d/mirrorlist

read -p "is the disk pre partitioned? (y/n) " x
case $x in
	[Nn]* ) fdisk /dev/sda;;
	* ) ;;
esac

mkfs.ext4 -F /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2

mount /dev/sda1 /mnt
pacstrap /mnt base linux linux-firmware intel-ucode xf86-video-intel vim man-db net-tools

genfstab -U /mnt >> /mnt/etc/fstab
echo -e "#\!/bin/bash\n\nln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime\nhwclock --systohc\n\necho \"archlinux\" > /etc/hostname\necho \"127.0.0.1\\\tlocalhost archlinux\\\n::1\\\t\\\tlocalhost\" >> /etc/hosts\n\necho \"LANG=en_US.UTF-8\" > /etc/locale.conf\nsed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen\necho \"KEYMAP=br-abnt2\" > /etc/vconsole.conf\n\nlocale-gen\n\npacman -S --noconfirm grub networkmanager sudo\n\nuseradd -mG wheel bm\nsed -i 's/@includedir /etc/sudoers.d/#@includedir /etc/sudoers.d/g' /etc/sudoers\nsed -i 's/#%wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers\n\nwhile true\ndo\n\tread -s -p \"password: \" pwd\n\techo\n\tread -s -p \"again: \" pwd2\n\techo\n\t[\"\$pwd\" == \"\$pwd2\" ] && break\n\techo \"passwords don't match\"\ndone\necho \"bm:\$pwd\" | chpasswd\n\ngrub-install /dev/sda && grub-mkconfig -o /boot/grub/grub.cfg && systemctl enable NetworkManager\n\nexit" > /mnt/root/installer2.sh

arch-chroot /mnt /mnt/root/installer2.sh
rm /mnt/root/installer2.sh

read -p "reboot? (y/n) " x
case $x in
	[Yy]* ) umount /mnt; rm $0; reboot;;
        * ) exit;;
esac
