#!/bin/bash
KEY="$1"

if [[ $KEY == "" ]]; then
	printf "Usage: $0 you-wpa-sec-key\n"
	printf "(You can also define your user key as a variable in this script)\n"
	exit
else
	if test -f "current.potfile"; then
	printf "Potfile current.pot already exists, it will be renamed to old.potfile and a new one will be downloaded.\n"
	printf "Backing up existing old.potfile and renaming current.potfile to old.potfile"
	TEMPDATE=$(date -r old.potfile "+%Y-%d-%m_%H-%M-%S")
	mkdir -p archive
	mv old.potfile archive/$TEMPDATE-old.potfile
	mv current.potfile old.potfile
	printf "Downloading potfile...\n"
	./get-pot.sh "$KEY" > temp-pot.txt
	printf "Saving cracked handshakes to current.potfile...\n"
	cat temp-pot.txt | sort | uniq -w 12 | cut -d ":" -f 1,3,4 > current.potfile
	rm temp-pot.txt
	printf "Comparing old and new potfiles and saving to newsites.txt\n"
	diff -u old.potfile current.potfile | grep -E "^\+" | tail -n +2 | tr -d "+" > newsites.txt
	else
	printf "No existing potfiles detected. Current one will get downloaded and saved to current.potfile\n"
	printf "Downloading potfile...\n"
	./get-pot.sh "$KEY" > temp-pot.txt
	printf "Saving cracked handshakes to current.potfile...\n"
	cat temp-pot.txt | sort | uniq -w 12 | cut -d ":" -f 1,3,4 > current.potfile
	rm temp-pot.txt
	fi
fi