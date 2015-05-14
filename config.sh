#!/bin/bash

# Airplay Script to run and start all airplay services in the house
# Eden Zik
# 06/08/2014

#aplay -l

killall shairport;
sudo service avahi-daemon restart;
sudo alsa force-reload;
sudo killall pulseaudio;
pulseaudio -D;
mpc stop;
sudo /etc/init.d/mpd restart;

# ================

# Initialization

declare -a music_zones=("Office" 
						"Living Room" 
						"Master Bedroom" 
						"Itamar Room" 
						"Eden Room" 
						"Kitchen");

declare -i port=13060;

for i in "${music_zones[@]}"
do
	room=`echo $i | tr '[:upper:]' '[:lower:]' | tr ' ' '-'`;
	shairport -a "$i" -d -p $port -o alsa -- -d $room;
	let port=port+1;
done

pacmd load-module module-equalizer-sink;

pacmd load-module module-combine-sink sink_name=combined slaves=alsa_output.usb-0d8c_C-Media_USB_Headphone_Set-00-Set.analog-stereo,alsa_output.usb-0d8c_C-Media_USB_Headphone_Set-00-Set_1.analog-stereo,alsa_output.usb-0d8c_C-Media_USB_Headphone_Set-00-Set_2.analog-stereo,alsa_output.usb-0d8c_C-Media_USB_Headphone_Set-00-Set_3.analog-stereo,alsa_output.usb-0d8c_C-Media_USB_Headphone_Set-00-Set_4.analog-stereo,alsa_output.pci-0000_00_14.2.analog-stereo;

pacmd set-default-sink combined;

shairport -a "Whole House" -d -p $port;

pids=pgrep shairport;

while : 
do
	if [ "$pids" != "echo pgrep shairport" ] 
	then
	  airplay;
	else
		sleep 20;
	fi
done
