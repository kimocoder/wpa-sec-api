#!/bin/bash
VERSION="v1.3.1"
SCRIPTPATH="$( cd "$(dirname "$0")" || { echo -e "\e[91mERROR\e[0m: Script path cannot be found" ; exit; } >/dev/null 2>&1 ; pwd -P )"
USER_AGENT="get-pot $VERSION, part of wpa-sec-api by Czechball (https://github.com/Czechball/wpa-sec-api)"
CONFIGFILE="$SCRIPTPATH"/config.txt

if test -f "$CONFIGFILE"; then
	:
else
	echo "$CONFIGFILE doesn't exist, creating a new one using setup.sh"
	"$SCRIPTPATH"/setup.sh
fi

source "$CONFIGFILE" || { echo -e "\e[91mERROR\e[0m: $CONFIGFILE doesn't exist in script path" ; exit; }

if curl --head -s "$DWPAURL" >/dev/null; then
	:
else
	echo -e "\e[91mERROR\e[0m: $DWPAURL couldn't be reached, check your internet connection"
	exit
fi

if [[ $DWPAKEY == "" ]]; then
	echo -e "\e[91mERROR\e[0m: No wpa-sec key supplied. Enter your key into $CONFIGFILE"
	exit
else
	curl -s "$DWPAURL/?api&dl=1" -b "key=$DWPAKEY" -A "$USER_AGENT"
fi