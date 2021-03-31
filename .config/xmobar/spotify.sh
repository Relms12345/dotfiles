#!/bin/bash
running=$(pidof spotify)
if [ "$running" != "" ]
then
	artist=$(playerctl -p spotify metadata artist)
	song=$(playerctl -p spotify metadata title | cut -c 1-60)
	echo -n "$artist · $song"
else
	echo "Spotify is not running"
fi
