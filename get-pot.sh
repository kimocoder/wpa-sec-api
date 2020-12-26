#!/bin/bash
VERSION="v1.2"
SCRIPTPATH="$( cd "$(dirname "$0")" || { echo -e "\e[91mERROR\e[0m: Script path cannot be found" ; exit; } >/dev/null 2>&1 ; pwd -P )"
USER_AGENT="get-pot $VERSION, part of wpa-sec-api by Czechball (https://github.com/Czechball/wpa-sec-api)"

source "$SCRIPTPATH"/creds.txt

if ping "wpa-sec.stanev.org" -c 1 -w 5 > /dev/null; then
	:
else
	echo -e "\e[91mERROR\e[0m: wpa-sec.stanev.org couldn't be reached, check your internet connection"
	exit
fi

if [[ $WPASECKEY == "" ]]; then
	echo -e "\e[91mERROR\e[0m: No wpa-sec key supplied. Enter your key into creds.txt"
	exit
else
	curl -s "https://wpa-sec.stanev.org/?api&dl=1" -b "key=$WPASECKEY" -A "$USER_AGENT"
fi