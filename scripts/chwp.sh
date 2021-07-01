#!/bin/sh

wpn="$(shuf -i 1-3 -n1)"
ext=".jpg"

if [ "$wpn" == 2 ]
then
        ext=".png"
fi

feh --bg-scale /home/bm/wallpapers/$wpn$ext
