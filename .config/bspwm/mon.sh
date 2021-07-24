#!/bin/bash

xrandr -q | rg -w connected | rg VGA1
if [[ "$(echo $?)" != "0" ]]
then
	feh --bg-scale wallpapers/1.jpg
	sed -i 's/^##$/bspc monitor LVDS1 -d I II III IV V VI VII VIII/g' /home/bm/.config/bspwm/bspwmrc
	sed -i "s/^###$/bspc rule -a firefox desktop='^1' follow=on; bspc rule -a vlc desktop='^7' follow=on state=fullscreen; bspc rule -a discord desktop='^5'; bspc rule -a Spotify desktop='^6' follow=on; bspc rule -a Thunar desktop='^7' follow=on/g" /home/bm/.config/bspwm/bspwmrc
else
	feh --bg-scale wallpapers/1.jpg --bg-fill wallpapers/2.png
	sed -i 's/bspc monitor L.*VIII/##/g' /home/bm/.config/bspwm/bspwmrc
	sed -i "s/bspc rule -a firefox desktop='^1' follow=on; bspc rule -a vlc desktop='^7' follow=on state=fullscreen; bspc rule -a discord desktop='^5'; bspc rule -a Spotify desktop='^6' follow=on; bspc rule -a Thunar desktop='^7' follow=on/###/g" /home/bm/.config/bspwm/bspwmrc
	/home/bm/.screenlayout/dualm.sh
fi
