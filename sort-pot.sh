#!/bin/bash
VERSION="v1.2"
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source "$SCRIPTPATH"/creds.txt

echo "wpa-sec-api $VERSION by Czechball"

if ping "wpa-sec.stanev.org" -c 1 -w 5 > /dev/null; then
	:
else
	echo -e "\e[91mERROR\e[0m: wpa-sec.stanev.org couldn't be reached, check your internet connection"
	exit
fi

if [[ $1 == "" ]]; then
	if [[ $WPASECKEY == "" ]]; then
		echo -e "\e[91mERROR\e[0m: No wpa-sec key supplied. Enter your key into creds.txt"
		exit
	else
		if test -f "current.potfile"; then
			if test -f "old.potfile"; then
				mkdir -p archive
				TEMPDATE=$(date -r old.potfile "+%Y-%m-%d_%H-%M-%S")
				mv old.potfile "archive/$TEMPDATE-old.potfile"
			fi
		echo -e "\e[1mcurrent.pot\e[0m exists, downloading new sites..."
		mv current.potfile old.potfile
		./get-pot.sh "$KEY" > temp-pot.txt
		sort temp-pot.txt | uniq -w 12 | cut -d ":" -f 1,3,4 > current.potfile
		rm temp-pot.txt
		test -f "old.potfile"
		diff -ua old.potfile current.potfile | grep -Ea "^\+" | tail -n +2 | tr -d "+" > newsites.txt
		WC_LINES=$(wc -l newsites.txt | cut -d " " -f 1)
		if [[ $WC_LINES == 0 ]]; then
			echo "No new sites cracked."
		else
			echo -e "\e[92m$WC_LINES new sites cracked.\e[0m"
		fi
		else
		echo -e "\e[33mNo previous potfiles detected, downloading sites...\e[0m"
		./get-pot.sh "$KEY" > temp-pot.txt
		sort temp-pot.txt | uniq -w 12 | cut -d ":" -f 1,3,4 > current.potfile
		rm temp-pot.txt
		fi
	fi
else
	if test -f "$1"; then
		echo "Parsing custom potfile: $1"
		sort "$1" | uniq -w 12 | cut -d ":" -f 1,3,4 > "parsed-$1"
	else
		echo  "$1 is not a valid file"
		exit
	fi
fi