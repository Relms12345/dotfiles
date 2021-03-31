#!/bin/sh
updates="$(checkupdates | wc -l)"
if [ $updates == 1 ]
then 
	echo "$(checkupdates | wc -l) update"
else 
	echo "$(checkupdates | wc -l) updates"
fi
