#!/bin/bash
KEY="$1"

if [[ KEY == "" ]]; then
	printf "Usage: $0 you-wpa-sec-key\n"
	printf "(You can also define your user key as a variable in this script)\n"
	exit
else
	printf "Downloading potfile...\n"
	./get-pot.sh "$KEY" > temp-pot.txt
	printf "Saving cracked handshakes to current.potfile...\n"
	cat temp-pot.txt | sort | uniq -u -w 12 | cut -d ":" -f 1,3,4 > current.potfile
	#rm temp-pot.txt
fi
