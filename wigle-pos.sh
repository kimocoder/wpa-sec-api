#!/bin/bash

# This script is used to process the newsites.txt or other potfiles outputted by sort-pot.sh

# Get your API name and API key from https://wigle.net/account
WIGLEAPINAME=""
WIGLEAPIKEY=""

if [[ $WIGLEAPINAME == "" ]]; then
	echo "Wigle API Name is missing. You can get it from https://wigle.net/account"
	exit
	if [[ $WIGLEAPIKEY == "" ]]; then
		echo "Wigle API Key is missing. You can get it from https://wigle.net/account"
		exit
	fi
fi

if [[ $1 == "" ]]; then
	echo "Usage: $0 input.txt"
	exit
fi

cat "$1" | while read -r line
do
	FILEMAC=$(echo "$line" | cut -d ":" -f 1)
	PSK=$(echo "$line" | cut -d ":" -f 3)
	SSID=$(echo "$line" | cut -d ":" -f 2)
	PARSEDMAC=$(echo "$FILEMAC" | sed -e 's/[0-9A-Fa-f]\{2\}/&:/g' -e 's/:$//')
	APICONTENT=$(curl -s -H 'Accept:application/json' -u $WIGLEAPINAME:$WIGLEAPIKEY --basic "https://api.wigle.net/api/v2/network/detail?netid=$PARSEDMAC")
	if ( echo "$APICONTENT" | grep 'too many queries today' ); then
		echo API QUERY LIMIT REACHED
		exit
	fi
	if ( echo "$APICONTENT" | grep '{"success":false,' > /dev/null ); then
		echo "null;null;$PARSEDMAC;$SSID;$PSK"
	else
		WIGLETRILAT=$(echo "$APICONTENT" | jq '.results[0].trilat')
		WIGLETRILONG=$(echo "$APICONTENT" | jq '.results[0].trilong')
		echo "$WIGLETRILAT;$WIGLETRILONG;$PARSEDMAC;$SSID;$PSK"
	fi
done