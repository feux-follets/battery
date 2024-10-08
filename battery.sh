#!/bin/bash

smc_cmd="/usr/local/bin/smc"
current_date=$(date '+%Y-%m-%d %H:%M:%S')
maintain_percent=80

battery_percent=$(pmset -g batt | tail -n1 | awk '{print $3}' | tr -d '%;')
echo "$current_date: Battery percent: $battery_percent%"
ch0c=$($smc_cmd -k CH0C -r | awk '{print $4}' | tr -d ')')

if [ "$battery_percent" -ge $maintain_percent ]; then
	if [ "$ch0c" -eq 00 ]; then
		echo "$current_date: Battery is >= $maintain_percent%. Enabling CH0C."
		$smc_cmd -k CH0C -w 01
	else
		echo "$current_date: CH0C already enabled."
	fi
elif [ "$battery_percent" -lt $maintain_percent ]; then
	if [ "$ch0c" -eq 01 ]; then
		echo "$current_date: Battery is < $maintain_percent%. Disabling CH0C."
		$smc_cmd -k CH0C -w 00
	else
		echo "$current_date: CH0C already disabled."
	fi
fi

exit 0
