#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar, using default config location ~/.config/polybar/config

xrandr -q | rg -w connected | rg VGA1
if [[ "$(echo $?)" != "0" ]]
then
	polybar LVDS1 &
else
	polybar LVDS1 &
	polybar VGA1 &
fi

echo "Polybar launched..."
