#!/bin/bash
source creds.txt

if [[ $WPASECKEY == "" ]]; then
	echo -e -e "\e[91mERROR\e[0m: No wpa-sec key supplied. Enter your key into creds.txt"
	exit
else
	if test -f "current.potfile"; then
		if test -f "old.potfile"; then
			mkdir -p archive
			TEMPDATE=$(date -r old.potfile "+%Y-%m-%d_%H-%M-%S")
			mv old.potfile archive/$TEMPDATE-old.potfile
		fi
	echo -e "\e[92m\e[1mcurrent.pot\e[0m\e[92m exists, downloading new sites\e[0m"
	mv current.potfile old.potfile
	./get-pot.sh "$KEY" > temp-pot.txt
	cat temp-pot.txt | sort | uniq -w 12 | cut -d ":" -f 1,3,4 > current.potfile
	rm temp-pot.txt
	test -f "old.potfile"
	diff -ua old.potfile current.potfile | grep -Ea "^\+" | tail -n +2 | tr -d "+" > newsites.txt
	else
	echo -e "\e[33mNo previous potfiles detected, downloading sites\e[0m"
	./get-pot.sh "$KEY" > temp-pot.txt
	cat temp-pot.txt | sort | uniq -w 12 | cut -d ":" -f 1,3,4 > current.potfile
	rm temp-pot.txt
	fi
fi