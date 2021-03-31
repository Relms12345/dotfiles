#!/bin/bash
theme="card_circle"
dir="$HOME/.config/rofi/powermenu"

# random colors
styles=($(ls -p --hide="colors.rasi" $dir/styles))
color="${styles[$(( $RANDOM % 8 ))]}"

# comment this line to disable random colors
#sed -i -e "s/@import .*/@import \"$color\"/g" $dir/styles/colors.rasi

# comment these lines to disable random style
#themes=($(ls -p --hide="powermenu.sh" --hide="styles" --hide="confirm.rasi" --hide="message.rasi" $dir))
#theme="${themes[$(( $RANDOM % 24 ))]}"

uptime=$(uptime -p | sed -e 's/up //g')

rofi_command="rofi -theme $dir/$theme"

# Options
shutdown=""
reboot=""
lock=""
suspend=""
logout=""

# Confirmation
confirm_exit() {
	rofi -dmenu\
		-i\
		-no-fixed-num-lines\
		-p "Are You Sure? : "\
		-theme $dir/confirm.rasi
}

# Message
msg() {
	rofi -theme "$dir/message.rasi" -e "Available Options  -  yes / y / no / n"
}

# Variable passed to rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

chosen="$(echo -e "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 2)"
case $chosen in
	$shutdown)
	ans=$(confirm_exit &)
	if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
		shutdown now
	elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
		exit 0
	else
		msg
	fi
	;;
	$reboot)
	ans=$(confirm_exit &)
	if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
		reboot
	elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
		exit 0
	else
		msg
	fi
	;;
	$lock)
	xscreensaver-command -lock
	;;
	$suspend)
	ans=$(confirm_exit &)
	if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
		systemctl suspend
	elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
		exit 0
	else
		msg
	fi
	;;
	$logout)
	ans=$(confirm_exit &)
	if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
		killall xmonad
	elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
		exit 0
	else
		msg
	fi
	;;
esac
