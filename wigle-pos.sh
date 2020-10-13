#!/bin/bash

# This script is used to process the newsites.txt or other potfiles outputted by sort-pot.sh

source creds.txt
VERSION="v1.1"

echo "wpa-sec-api $VERSION by Czechball"
if [[ $WIGLEAPINAME == "" ]]; then
	echo -e "\e[91mERROR\e[0m: Wigle API Name is missing. You can get it from https://wigle.net/account"
	echo "Enter your credentials into creds.txt"
	exit
	if [[ $WIGLEAPIKEY == "" ]]; then
		echo -e "\e[91mERROR\e[0m: Wigle API Key is missing. You can get it from https://wigle.net/account"
		echo "Enter your credentials into creds.txt"
		exit
	fi
fi

if [[ $NICK == "" ]]; then
	echo -e "\e[91mERROR\e[0m: No user nickname defined. Put your username into creds.txt"
	exit
fi

DATE=$(date --iso-8601)
FILENAME="${DATE}_$NICK.txt"

if [[ $1 == "" ]]; then
	echo "Usage: $0 newsites.txt"
	exit
fi

save_file ()
{
	WC_LINES=$(wc -l $1 | cut -d " " -f 1)
	CURRENT_LINE=1
	cat "$1" | while read -r line
	do
		FILEMAC=$(echo "$line" | cut -d ":" -f 1)
		PSK=$(echo "$line" | cut -d ":" -f 3)
		SSID=$(echo "$line" | cut -d ":" -f 2)
		PARSEDMAC=$(echo "$FILEMAC" | sed -e 's/[0-9A-Fa-f]\{2\}/&:/g' -e 's/:$//')
		APICONTENT=$(curl -s -H 'Accept:application/json' -u $WIGLEAPINAME:$WIGLEAPIKEY --basic "https://api.wigle.net/api/v2/network/detail?netid=$PARSEDMAC")
		echo -e "\e[1A\e[KSaving networks to $FILENAME... ($CURRENT_LINE/$WC_LINES) - [$SSID]"
		if ( echo "$APICONTENT" | grep 'too many queries today' ); then
			echo -e "\e[91mERROR\e[0m: API query limit reached"
			exit
		fi
		if ( echo "$APICONTENT" | grep '{"success":false,' > /dev/null ); then
			echo "null;null;$PARSEDMAC;$SSID;$PSK" >> $FILENAME
			((CURRENT_LINE=$CURRENT_LINE+1))
		else
			WIGLETRILAT=$(echo "$APICONTENT" | jq '.results[0].trilat')
			WIGLETRILONG=$(echo "$APICONTENT" | jq '.results[0].trilong')
			echo "$WIGLETRILAT;$WIGLETRILONG;$PARSEDMAC;$SSID;$PSK" >> $FILENAME
			((CURRENT_LINE=$CURRENT_LINE+1))
		fi
	done
}

if test -f "$FILENAME"; then
read -p "$FILENAME already exists, do you want to append to it? (Y/n) " -n 1 -r
echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		save_file "$1"
	else
		exit
	fi
else
save_file "$1"
fi