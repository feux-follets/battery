#!/bin/bash

smc_cmd="/usr/local/bin/smc"
smc_key="CHTE"

current_date=$(date '+%Y-%m-%d %H:%M:%S')
maintain_percent=80
sail_percent=50

function get_accurate_battery_percentage() {
	MaxCapacity=$(ioreg -l -n AppleSmartBattery -r | grep "\"AppleRawMaxCapacity\" =" | awk '{ print $3 }' | tr ',' '.')
	CurrentCapacity=$(ioreg -l -n AppleSmartBattery -r | grep "\"AppleRawCurrentCapacity\" =" | awk '{ print $3 }' | tr ',' '.')
	accurate_battery_percentage=$(echo "$CurrentCapacity*100/$MaxCapacity" | bc)
	echo "$accurate_battery_percentage"
}

battery_percent=$(get_accurate_battery_percentage)
echo "$current_date: Battery percent: $battery_percent%"

chte=$($smc_cmd -k "$smc_key" -r | awk '{print $(NF-3)}')

if [ "$battery_percent" -ge $maintain_percent ]; then
	if [ "$chte" -eq 00 ]; then
		echo "$current_date: Battery is >= $maintain_percent%. Disable charging."
		$smc_cmd -k "$smc_key" -w 01000000
	else
		echo "$current_date: Charging already disabled."
	fi
else
	if [ "$battery_percent" -ge $sail_percent ]; then
		if [ "$chte" -eq 01 ]; then
			echo "$current_date: Battery is >= $sail_percent%. Battery is not charging."
		else
			echo "$current_date: Battery is >= $sail_percent%. Battery is charging."
		fi
	else
		if [ "$chte" -eq 01 ]; then
			echo "$current_date: Battery is < $sail_percent%. Enable charging."
			$smc_cmd -k "$smc_key" -w 00000000
		else
			echo "$current_date: Charging already enabled."
		fi
	fi
fi

exit 0
