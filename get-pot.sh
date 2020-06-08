#!/bin/bash

KEY="$1"

if [[ $KEY == "" ]]; then
	printf "Usage: $0 you-wpa-sec-key\n"
	printf "(You can also define your user key as a variable in this script)\n"
	exit
else
	curl "https://wpa-sec.stanev.org/?api&dl=1" -b "key=$KEY" -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36'
fi