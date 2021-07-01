#!/bin/bash

# common gaps - inner: 7, outer: 9

gc="/home/bm/scripts/gc" # gaps counter
config="/home/bm/.config/i3/config"

if [ "$#" == 0 ]
then
	if [[ $(cat "$gc") == "0" ]]   # 0 = no gaps
        then
                sed -i 's/#gaps/gaps/g' $config
                echo 1 > "$gc"
                i3-msg restart
	elif [[ $(cat "$gc") == "1" ]] # 1 = common gaps
	then
                sed -i 's/^gaps/#gaps/g' $config
                echo 0 > "$gc"
                i3-msg restart
	else		      # 2 = ss gaps
		:
	fi	
else
	if [[ $(cat "$gc") == "0" ]]
        then
                sed -i 's/#gaps inner 7/gaps inner 17/g' $config
                sed -i 's/#gaps outer 9/gaps outer 19/g' $config
                echo 2 > "$gc"
                i3-msg restart
	elif [[ $(cat "$gc") == "1" ]]
	then
                sed -i 's/gaps inner 7/gaps inner 17/g' $config
                sed -i 's/gaps outer 9/gaps outer 19/g' $config
                echo 2 > "$gc"
                i3-msg restart
        else
		sed -i 's/gaps inner 17/gaps inner 7/g' $config
		sed -i 's/gaps outer 19/gaps outer 9/g' $config
		echo 1 > "$gc"
		i3-msg restart
	fi
fi
